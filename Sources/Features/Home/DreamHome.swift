import SwiftUI

/// Owns capture/navigation state; child views only present values and forward actions.
struct DreamHome: View {
  @Environment(DreamStore.self) private var store
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.openURL) private var openURL
  @State private var composer = DreamComposer()
  @State private var voice = DreamVoice()
  @State private var mode: DreamCaptureMode?
  @State private var voiceRequest = 0
  @State private var voicePrefix = ""
  @State private var interpretRequest = 0
  @State private var journal = false
  @State private var openedDream: DreamEntry?
  @State private var captureError: String?
  @FocusState private var writing: Bool

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          if mode == nil {
            HomeDreamPreview(latest: latest, onOpen: openLatest)
          } else {
            DreamCaptureEditor(
              mode: mode, composer: composer, voice: voice,
              writing: $writing, onToggleVoice: toggleVoice, onOpenSettings: openSettings)
          }
          if let error = captureError ?? composer.draftMessage ?? store.error {
            Text(error).foregroundStyle(.orange).font(.footnote)
          }
        }
        .padding(.horizontal, 24).frame(maxWidth: 700).frame(maxWidth: .infinity)
      }
      .scrollDismissesKeyboard(.interactively)
      .background(Color("Paper"))
      .safeAreaBar(edge: .bottom) {
        if mode == nil {
          DreamCaptureActions(onRecord: record, onWrite: write)
        } else {
          InterpretDreamButton(
            isCreating: composer.isCreating, canInterpret: canSave,
            onInterpret: requestInterpretation)
          if mode == .voice && voice.hasRecording && composer.text.isEmpty {
            Button("Save audio for later", action: saveAudio).padding(.bottom, 8)
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", action: cancelCapture)
        }.hidden(mode == nil)
        ToolbarItem(placement: .primaryAction) {
          Button("Journal", systemImage: "book.closed", action: openJournal)
            .accessibilityIdentifier("openJournal")
        }.hidden(mode != nil)
      }
      .sheet(isPresented: $journal) { DreamJournal(onNewPage: newNotebookPage) }
      .sheet(item: $openedDream) { entry in
        NavigationStack {
          DreamDetail(entry: entry)
            .toolbar {
              ToolbarItem(placement: .confirmationAction) { Button("Done", action: closeDream) }
            }
        }
      }
      .task(id: voiceRequest, voiceAction)
      .task(id: interpretRequest, interpret)
      .task(id: voice.isRecording, voice.monitor)
      .task(id: composer.draft, autosave)
      .onChange(of: voice.transcript, appendTranscript)
      .onChange(of: scenePhase, handleScene)
    }
  }

  private var latest: DreamEntry? { store.entries.first }
  private var canSave: Bool {
    mode != nil && !voice.isRecording && !voice.isPreparing && !voice.isTranscribing
      && !composer.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
  // MARK: - Capture actions

  private func record() {
    voicePrefix = composer.text
    mode = .voice
    writing = false
    voiceRequest += 1
  }
  private func write() {
    mode = .text
    writing = true
  }
  private func toggleVoice() {
    if !voice.isRecording { voicePrefix = composer.text }
    voiceRequest += 1
  }
  private func voiceAction() async {
    guard voiceRequest > 0 else { return }
    if voice.isRecording { await voice.finish() } else { await voice.start() }
  }
  private func autosave() async {
    do {
      try await Task.sleep(for: .milliseconds(350))
      composer.persistDraft()
    } catch {}
  }
  private func appendTranscript() {
    guard let text = voice.transcript, !text.isEmpty else { return }
    composer.text = voicePrefix.isEmpty ? text : "\(voicePrefix)\n\(text)"
  }
  // MARK: - Interpretation and persistence

  private func requestInterpretation() {
    writing = false
    composer.persistDraft()
    interpretRequest += 1
  }
  private func interpret() async {
    guard interpretRequest > 0, canSave else { return }
    await composer.create()
    guard !Task.isCancelled, var entry = composer.result else { return }
    do {
      if mode == .voice { entry.audioFilename = try voice.preserveRecording(for: entry.id) }
      let poster: Data?
      if let recipe = entry.visualRecipe {
        poster = try await PortraitService.shared.png(recipe: recipe)
      } else {
        poster = nil
      }
      guard !Task.isCancelled else { return }
      if store.save(entry, portraitData: poster) {
        if mode == .voice { voice.discardSavedDraft() }
        composer.clearDraft()
        mode = nil
        writing = false
        openedDream = store.entries.first { $0.id == entry.id } ?? entry
      }
    } catch { captureError = "Your recording is safe. Please try again." }
  }
  private func saveAudio() {
    guard voice.hasRecording, !voice.isRecording, !voice.isTranscribing else { return }
    var entry = composer.unassistedEntry()
    do {
      if mode == .voice { entry.audioFilename = try voice.preserveRecording(for: entry.id) }
      if store.save(entry) {
        if mode == .voice { voice.discardSavedDraft() }
        composer.clearDraft()
        mode = nil
        writing = false
        captureError = nil
      }
    } catch { captureError = "Your recording is safe. Please try saving again." }
  }
  // MARK: - Navigation and lifecycle

  private func cancelCapture() {
    voiceRequest = 0
    interpretRequest = 0
    voice.cleanup()
    composer.persistDraft()
    mode = nil
    writing = false
  }
  private func handleScene() {
    if scenePhase == .background {
      voice.cleanup()
      composer.persistDraft()
    }
  }
  private func openJournal() { journal = true }
  private func newNotebookPage() {
    journal = false
    write()
  }
  private func openLatest() { openedDream = latest }
  private func closeDream() { openedDream = nil }
  private func openSettings() { if let url = URL(string: "app-settings:") { openURL(url) } }
}
