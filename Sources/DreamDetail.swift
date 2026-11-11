import SwiftUI

struct DreamDetail: View {
    @State private var entry: DreamEntry
    @State private var reader = DreamComposer(recoverDraft: false)
    @State private var reflectionRequest = 0
    @State private var nightRequest = 0
    @State private var confirmDeletion = false
    @State private var editing = false
    @State private var export: URL?
    @State private var exportError: String?
    @Environment(DreamStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    init(entry: DreamEntry) { _entry = State(initialValue: entry) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DreamArtwork(seed: entry.seed, feeling: entry.feeling, intensity: entry.intensity,
                             heartRate: entry.night?.heartRate, motif: entry.motif)
                    .frame(maxHeight: 390)
                Text(entry.date, format: .dateTime.day().month(.wide).year())
                    .font(.footnote).foregroundStyle(Color("SecondaryInk"))
                if let title = entry.title, !title.isEmpty { Text(title).font(.title).fontDesign(.serif) }
                if let filename = entry.audioFilename { DreamAudioPlayback(filename: filename) }
                Text(entry.text).textSelection(.enabled)
                if !entry.reflection.isEmpty {
                    Divider()
                    Text(entry.usedAI ? "A possible meaning" : "A moment to reflect")
                        .font(.title2).fontDesign(.serif)
                    Text(entry.reflection)
                    Text(entry.question).font(.title3).fontDesign(.serif)
                    if !entry.usedAI {
                        Text("Apple Intelligence is not ready. This is a reflection prompt, not an AI interpretation.")
                            .font(.footnote).foregroundStyle(Color("SecondaryInk"))
                    }
                } else if !entry.text.isEmpty {
                    Button("Interpret dream", systemImage: "text.bubble", action: requestReflection)
                        .buttonStyle(.bordered).controlSize(.large).disabled(reader.isCreating)
                }
                if reader.isCreating { ProgressView("Finding a possible meaning…") }
                if reader.status != nil {
                    Text("A possibility to explore. The meaning is yours.")
                        .font(.footnote).foregroundStyle(Color("SecondaryInk"))
                }
                HStack {
                    Button("Edit", systemImage: "pencil", action: edit).frame(minHeight: 44).disabled(reader.isCreating)
                    Spacer()
                    if let export {
                        ShareLink(item: export) { Label("Share", systemImage: "square.and.arrow.up") }
                    } else { Button("Share", systemImage: "square.and.arrow.up", action: prepareExport) }
                }.font(.subheadline)
                DisclosureGroup("The night") {
                    VStack(alignment: .leading, spacing: 16) {
                        if let night = entry.night { NightSummary(night: night) }
                        else {
                            Button("Add sleep data", systemImage: "heart", action: requestNight)
                                .frame(minHeight: 44).disabled(reader.isLoadingNight)
                        }
                        if reader.isLoadingNight { ProgressView() }
                        Text(reader.nightMessage).font(.footnote).foregroundStyle(Color("SecondaryInk"))
                    }.padding(.top)
                }
                Button("Delete dream", role: .destructive, action: requestDeletion).frame(minHeight: 44)
                    .confirmationDialog("Delete this dream?", isPresented: $confirmDeletion) {
                        Button("Delete", role: .destructive, action: delete)
                    }
                if let error = store.error ?? exportError { Text(error).foregroundStyle(.orange).font(.footnote) }
            }
            .padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity)
        }
        .background(Color("Paper"))
        .sheet(isPresented: $editing) { DreamEditView(entry: entry, onSave: applyEdit) }
        .task(id: reflectionRequest, reflect)
        .task(id: nightRequest, loadNight)
        .onDisappear(perform: removeExport)
    }

    private func requestReflection() { reflectionRequest += 1 }
    private func reflect() async {
        guard reflectionRequest > 0 else { return }
        let snapshot = entry
        reader.text = snapshot.text
        reader.feeling = snapshot.feeling
        reader.intensity = snapshot.intensity
        reader.night = snapshot.night
        await reader.create()
        guard !Task.isCancelled, let result = reader.result, entry.text == snapshot.text else { return }
        var updated = snapshot
        updated.reflection = result.reflection
        updated.question = result.question
        updated.usedAI = result.usedAI
        updated.motif = result.motif
        updated.feeling = result.feeling
        updated.intensity = result.intensity
        if snapshot.title?.isEmpty != false { updated.title = result.title }
        if store.save(updated) { entry = updated; removeExport() }
    }
    private func requestNight() { nightRequest += 1 }
    private func loadNight() async {
        guard nightRequest > 0 else { return }
        await reader.loadNight(before: entry.date)
        guard !Task.isCancelled, let night = reader.night else { return }
        var updated = entry
        updated.night = night
        if store.save(updated) { entry = updated }
    }
    private func edit() { editing = true }
    private func applyEdit(_ updated: DreamEntry) { entry = updated; removeExport() }
    private func requestDeletion() { confirmDeletion = true }
    private func delete() { store.delete(entry); if store.error == nil { dismiss() } }
    private func prepareExport() {
        let artwork = DreamCanvas(seed: entry.seed, feeling: entry.feeling, intensity: entry.intensity,
                                  motif: entry.motif, heartRate: nil)
            .frame(width: 1080, height: 1080).background(Color(red: 0.045, green: 0.047, blue: 0.055))
        let renderer = ImageRenderer(content: artwork)
        guard let data = renderer.uiImage?.pngData() else { exportError = "The image could not be prepared."; return }
        let url = URL.temporaryDirectory.appending(path: "DREAM-\(entry.id.uuidString).png")
        do { try data.write(to: url, options: [.atomic, .completeFileProtection]); export = url }
        catch { exportError = "The image could not be prepared." }
    }
    private func removeExport() { if let export { try? FileManager.default.removeItem(at: export); self.export = nil } }
}
