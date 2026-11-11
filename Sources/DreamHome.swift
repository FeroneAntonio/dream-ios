import SwiftUI

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
                        Text("Give your dream a shape.").font(.title2).fontDesign(.serif).padding(.top, 24)
                        Button(action: openLatest) {
                            DreamArtwork(seed: latest?.seed ?? 91, feeling: latest?.feeling ?? .confusion,
                                         intensity: latest?.intensity ?? 0.8, heartRate: latest?.night?.heartRate,
                                         motif: latest?.motif ?? .flow).frame(maxHeight: 470)
                        }
                        .buttonStyle(.plain).disabled(latest == nil)
                        .accessibilityLabel(latest == nil ? "Visual exploration" : "Open your latest dream")
                        Text(latest?.displayTitle ?? "What stayed with you?")
                            .font(.body).foregroundStyle(Color("SecondaryInk")).lineLimit(2)
                    } else {
                        if mode == .voice {
                            VoiceControl(voice: voice, action: toggleVoice).disabled(composer.isCreating)
                            if voice.needsSettings { Button("Open Settings", action: openSettings) }
                        } else {
                            Text("What did you dream?").font(.title2).fontDesign(.serif)
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 24)
                        }
                        TextField("Write what you remember…", text: $composer.text, axis: .vertical)
                            .font(.title3).lineLimit(6...16).focused($writing)
                            .disabled(voice.isRecording || voice.isPreparing || voice.isTranscribing || composer.isCreating)
                            .accessibilityIdentifier("dreamText")
                        if composer.restoredDraft {
                            Text("Draft restored").font(.footnote).foregroundStyle(Color("SecondaryInk"))
                        }
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
                    HStack(spacing: 12) {
                        Button("Record", systemImage: "mic", action: record)
                            .buttonStyle(.borderedProminent).tint(.white).foregroundStyle(.black)
                            .accessibilityIdentifier("newVoiceDream")
                        Button("Write", systemImage: "square.and.pencil", action: write)
                            .buttonStyle(.bordered).tint(.white).accessibilityIdentifier("newTextDream")
                    }.controlSize(.large).frame(maxWidth: .infinity).padding(.vertical, 16)
                } else {
                    Button(action: requestInterpretation) {
                        HStack {
                            if composer.isCreating { ProgressView().tint(.black) }
                            Text(composer.isCreating ? "Interpreting…" : "Interpret dream")
                        }
                    }
                        .buttonStyle(.borderedProminent).tint(.white).foregroundStyle(.black)
                        .controlSize(.large).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .disabled(!canSave || composer.isCreating).accessibilityIdentifier("createDream")
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
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done", action: closeDream) } }
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
        mode != nil && !voice.isRecording && !voice.isPreparing && !voice.isTranscribing &&
        !composer.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private func record() { voicePrefix = composer.text; mode = .voice; writing = false; voiceRequest += 1 }
    private func write() { mode = .text; writing = true }
    private func toggleVoice() { if !voice.isRecording { voicePrefix = composer.text }; voiceRequest += 1 }
    private func voiceAction() async {
        guard voiceRequest > 0 else { return }
        if voice.isRecording { await voice.finish() } else { await voice.start() }
    }
    private func autosave() async {
        do { try await Task.sleep(for: .milliseconds(350)); composer.persistDraft() } catch { }
    }
    private func appendTranscript() {
        guard let text = voice.transcript, !text.isEmpty else { return }
        composer.text = voicePrefix.isEmpty ? text : "\(voicePrefix)\n\(text)"
    }
    private func requestInterpretation() { writing = false; composer.persistDraft(); interpretRequest += 1 }
    private func interpret() async {
        guard interpretRequest > 0, canSave else { return }
        await composer.create()
        guard !Task.isCancelled, var entry = composer.result else { return }
        do {
            if mode == .voice { entry.audioFilename = try voice.preserveRecording(for: entry.id) }
            if store.save(entry) {
                if mode == .voice { voice.discardSavedDraft() }
                composer.clearDraft()
                mode = nil
                writing = false
                openedDream = entry
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
    private func cancelCapture() {
        voiceRequest = 0
        interpretRequest = 0
        voice.cleanup()
        composer.persistDraft()
        mode = nil
        writing = false
    }
    private func handleScene() { if scenePhase == .background { voice.cleanup(); composer.persistDraft() } }
    private func openJournal() { journal = true }
    private func newNotebookPage() { journal = false; write() }
    private func openLatest() { openedDream = latest }
    private func closeDream() { openedDream = nil }
    private func openSettings() { if let url = URL(string: "app-settings:") { openURL(url) } }
}
