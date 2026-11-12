import SwiftUI

struct DreamDetail: View {
  @State private var entry: DreamEntry
  @State private var reader = DreamComposer(recoverDraft: false)
  @State private var reflectionRequest = 0
  @State private var nightRequest = 0
  @State private var confirmDeletion = false
  @State private var editing = false
  @State private var refining = false
  @State private var recreating = false
  @State private var exportRequest = 0
  @State private var export: URL?
  @State private var exportError: String?
  @Environment(DreamStore.self) private var store
  @Environment(\.dismiss) private var dismiss

  init(entry: DreamEntry) { _entry = State(initialValue: entry) }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        DreamPortrait(entry: entry, pixels: 1080, animates: false)
          .frame(maxHeight: 390)
        if let recipe = entry.visualRecipe {
          PortraitExplanation(
            recipe: recipe, usesEarlierText: entry.portraitUsesEarlierText,
            onRecreate: recreatePortrait)
        }
        Button("Refine portrait", systemImage: "slider.horizontal.3", action: refinePortrait)
          .frame(minHeight: 44).disabled(reader.isCreating).accessibilityIdentifier(
            "refinePortrait")
        Text(entry.date, format: .dateTime.day().month(.wide).year())
          .font(.footnote).foregroundStyle(Color("SecondaryInk"))
        if let title = entry.title, !title.isEmpty { Text(title).font(.title).fontDesign(.serif) }
        if let filename = entry.audioFilename { DreamAudioPlayback(filename: filename) }
        Text(entry.text).textSelection(.enabled)
        if let emotions = entry.emotions {
          DreamEmotionView(
            analysis: emotions, motif: entry.motif, usesVisualGrammar: entry.visualRecipe != nil)
        }
        DreamReflectionSection(
          entry: entry, isCreating: reader.isCreating,
          hasStatus: reader.status != nil, onInterpret: requestReflection)
        HStack {
          Button("Edit", systemImage: "pencil", action: edit).frame(minHeight: 44).disabled(
            reader.isCreating)
          Spacer()
          if let export {
            ShareLink(item: export) { Label("Share", systemImage: "square.and.arrow.up") }
          } else {
            Button("Share", systemImage: "square.and.arrow.up", action: requestExport)
          }
        }.font(.subheadline)
        DreamNightSection(
          night: entry.night, isLoading: reader.isLoadingNight,
          message: reader.nightMessage, onLoad: requestNight)
        SLAMSSResearchSection(
          report: entry.researchSleep, dreamDate: entry.date, onImport: importResearchSleep)
        Button("Delete dream", role: .destructive, action: requestDeletion).frame(minHeight: 44)
          .confirmationDialog("Delete this dream?", isPresented: $confirmDeletion) {
            Button("Delete", role: .destructive, action: delete)
          }
        if let error = store.error ?? exportError {
          Text(error).foregroundStyle(.orange).font(.footnote)
        }
      }
      .padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity)
    }
    .background(Color("Paper"))
    .sheet(isPresented: $editing) { DreamEditView(entry: entry, onSave: applyEdit) }
    .sheet(isPresented: $refining) {
      PortraitRefinementView(entry: entry, recreate: recreating, onConfirm: savePortrait)
    }
    .task(id: exportRequest, prepareExport)
    .task(id: reflectionRequest, reflect)
    .task(id: nightRequest, loadNight)
    .onDisappear(perform: removeExport)
  }

  // MARK: - Written reading

  private func requestReflection() { reflectionRequest += 1 }
  private func reflect() async {
    guard reflectionRequest > 0 else { return }
    let snapshot = entry
    reader.text = snapshot.text
    reader.feeling = snapshot.feeling
    reader.intensity = snapshot.intensity
    reader.night = snapshot.night
    await reader.create()
    guard !Task.isCancelled, let result = reader.result, entry.text == snapshot.text,
      store.entries.contains(where: { $0.id == snapshot.id })
    else { return }
    // Preserve any night/context update that completed while the model awaited.
    var updated = entry
    updated.reflection = result.reflection
    updated.question = result.question
    updated.usedAI = result.usedAI
    // A new written reading never silently replaces the saved portrait.
    updated.emotions = result.emotions ?? entry.emotions
    if updated.title?.isEmpty != false { updated.title = result.title }
    if store.save(updated) {
      entry = updated
      removeExport()
    }
  }
  // MARK: - Night context

  private func requestNight() { nightRequest += 1 }
  private func loadNight() async {
    guard nightRequest > 0 else { return }
    await reader.loadNight(before: entry.date)
    guard !Task.isCancelled, let night = reader.night,
      store.entries.contains(where: { $0.id == entry.id })
    else { return }
    var updated = entry
    updated.night = night
    if store.save(updated) { entry = updated }
  }
  // MARK: - Editing and deletion

  private func edit() { editing = true }
  private func importResearchSleep(_ report: SLAMSSReport) {
    var updated = entry
    updated.researchSleep = report
    if store.save(updated) { entry = updated }
  }
  private func applyEdit(_ updated: DreamEntry) {
    entry = updated
    removeExport()
  }
  private func requestDeletion() { confirmDeletion = true }
  private func delete() {
    store.delete(entry)
    if store.error == nil { dismiss() }
  }
  // MARK: - Portrait confirmation

  private func refinePortrait() {
    recreating = false
    refining = true
  }
  private func recreatePortrait() {
    recreating = true
    refining = true
  }
  private func savePortrait(_ recipe: DreamVisualRecipe) async -> Bool {
    do {
      let data = try await PortraitService.shared.png(recipe: recipe)
      try Task.checkCancellation()
      guard store.entries.contains(where: { $0.id == entry.id }) else { return false }
      var updated = entry
      updated.visualRecipe = recipe
      if let energy = recipe.userAdjustments.energy { updated.intensity = energy }
      guard store.save(updated, portraitData: data) else { return false }
      entry = store.entries.first { $0.id == updated.id } ?? updated
      removeExport()
      return true
    } catch {
      exportError = "Your portrait could not be saved. Your original is safe."
      return false
    }
  }
  // MARK: - Sharing

  private func requestExport() { exportRequest += 1 }
  private func prepareExport() async {
    guard exportRequest > 0 else { return }
    if let recipe = entry.visualRecipe {
      do {
        let data = try await PortraitService.shared.png(
          recipe: recipe, snapshot: store.snapshotURL(for: entry))
        try Task.checkCancellation()
        let url = URL.temporaryDirectory.appending(path: "DREAM-\(entry.id.uuidString).png")
        try data.write(to: url, options: [.atomic, .completeFileProtection])
        export = url
      } catch { exportError = "The image could not be prepared." }
      return
    }
    let legacy =
      entry.legacyPortrait
      ?? LegacyPortrait(
        seed: entry.seed, feeling: entry.feeling, intensity: entry.intensity, motif: entry.motif)
    let artwork = DreamCanvas(
      seed: legacy.seed, feeling: legacy.feeling, intensity: legacy.intensity, motif: legacy.motif,
      heartRate: nil
    )
    .frame(width: 1080, height: 1080).background(Color(red: 0.045, green: 0.047, blue: 0.055))
    let renderer = ImageRenderer(content: artwork)
    guard let data = renderer.uiImage?.pngData() else {
      exportError = "The image could not be prepared."
      return
    }
    let url = URL.temporaryDirectory.appending(path: "DREAM-\(entry.id.uuidString).png")
    do {
      try data.write(to: url, options: [.atomic, .completeFileProtection])
      export = url
    } catch { exportError = "The image could not be prepared." }
  }
  private func removeExport() {
    if let export {
      try? FileManager.default.removeItem(at: export)
      self.export = nil
    }
  }
}
