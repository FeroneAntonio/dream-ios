import AVFoundation
import Speech
import Observation

@MainActor @Observable
final class DreamVoice {
    var transcript: String?
    var message: String?
    var isRecording = false
    var isTranscribing = false
    var isPreparing = false
    var needsSettings = false
    var elapsed: TimeInterval = 0
    var level: Double = 0
    private(set) var hasRecording = false
    private let directory: URL
    private let draftFile: URL
    private var recordedFile: URL
    private var engine: AVAudioEngine?
    private var processor: SpeechCaptureProcessor?
    private var analyzer: SpeechAnalyzer?
    private var resultsTask: Task<Void, Never>?
    private var deactivationTask: Task<Void, Never>?
    private var sessionIsActive = false
    private var tapInstalled = false

    init(directory: URL = .documentsDirectory) {
        self.directory = directory
        draftFile = directory.appending(path: "voice-draft.caf")
        let previous = directory.appending(path: "voice-draft.m4a")
        recordedFile = FileManager.default.fileExists(atPath: draftFile.path()) ? draftFile : previous
        hasRecording = FileManager.default.fileExists(atPath: recordedFile.path())
    }

    func start() async {
        guard !isPreparing, !isRecording, !isTranscribing else { return }
        trace("Microphone button received")
        isPreparing = true
        defer { isPreparing = false }
        needsSettings = false
        message = "Waiting for the microphone…"
        transcript = nil
        await deactivationTask?.value
        let allowed = await AVAudioApplication.requestRecordPermission()
        trace("Microphone permission: \(allowed)")
        guard !Task.isCancelled else { return }
        guard allowed else {
            needsSettings = true
            message = "Allow microphone access in Settings to record."
            return
        }
        do {
            message = "Preparing English dictation. This only happens once…"
            trace("Preparing English speech assets")
            let transcriber = try await SpeechModelProvider.prepareEnglish()
            try Task.checkCancellation()
            message = "Opening the microphone…"
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
            guard try await session.activate(options: []) else { throw CocoaError(.featureUnsupported) }
            sessionIsActive = true
            try Task.checkCancellation()
            let engine = AVAudioEngine()
            let inputFormat = engine.inputNode.outputFormat(forBus: 0)
            guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0,
                  let analysisFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber], considering: inputFormat) else {
                throw CocoaError(.featureUnsupported)
            }
            let stream = AsyncThrowingStream<AnalyzerInput, Error>.makeStream()
            recordedFile = draftFile
            let processor = try SpeechCaptureProcessor(inputFormat: inputFormat, outputFormat: analysisFormat,
                                                       recordingURL: recordedFile, continuation: stream.continuation)
            self.processor = processor
            let analyzer = SpeechAnalyzer(modules: [transcriber])
            self.analyzer = analyzer
            self.engine = engine
            try await analyzer.start(inputSequence: stream.stream)
            resultsTask = Task { [weak self] in
                var transcript = DreamTranscript()
                do {
                    for try await result in transcriber.results {
                        guard let self, !Task.isCancelled else { return }
                        let text = String(result.text.characters)
                        self.transcript = transcript.accept(start: result.range.start.seconds, text: text, isFinal: result.isFinal)
                        self.trace("Live transcription received")
                    }
                } catch is CancellationError { }
                catch {
                    self?.message = "Your audio is safe. The transcript could not be completed."
                    self?.trace("Live transcription error: \((error as NSError).domain) \((error as NSError).code)")
                }
            }
            try engine.inputNode.installAudioTap(onBus: 0, bufferSize: 4096, format: inputFormat) { buffer, _ in
                processor.process(AVAudioPCMBuffer(copying: buffer))
            }
            tapInstalled = true
            engine.prepare()
            try engine.start()
            try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: recordedFile.path())
            hasRecording = false
            elapsed = 0
            isRecording = true
            message = "Listening. Your words will appear here."
            trace("Audio engine running: \(engine.isRunning)")
        } catch is CancellationError { cleanup() }
        catch {
            cleanup()
            message = "Could not prepare English dictation. Check your connection and try again."
            trace("Voice setup error: \((error as NSError).domain) \((error as NSError).code)")
        }
    }

    func finish() async {
        guard engine != nil else { return }
        stopInput()
        isTranscribing = true
        defer { isTranscribing = false; releaseSession() }
        do {
            try await analyzer?.finalizeAndFinishThroughEndOfInput()
            await resultsTask?.value
            message = "Audio and text are ready."
            trace("Live transcription finalized")
        } catch {
            message = "Your audio is ready to save, even without a transcript."
            trace("Finalization failed; audio preserved")
        }
        resultsTask = nil
        analyzer = nil
    }

    func monitor() async {
        while isRecording && !Task.isCancelled {
            if let meter = processor?.meter() { elapsed = meter.elapsed; level = meter.level }
            if elapsed >= 120 { await finish(); return }
            do { try await Task.sleep(for: .milliseconds(120)) } catch { return }
        }
    }

    func preserveRecording(for id: UUID) throws -> String? {
        guard hasRecording else { return nil }
        let audioDirectory = directory.appending(path: "audio", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
        let filename = "\(id.uuidString).\(recordedFile.pathExtension)"
        let destination = audioDirectory.appending(path: filename)
        try FileManager.default.copyItem(at: recordedFile, to: destination)
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: destination.path())
        return filename
    }

    func discardSavedDraft() {
        try? FileManager.default.removeItem(at: recordedFile)
        hasRecording = false
        transcript = nil
        message = nil
    }

    func cleanup() {
        stopInput()
        resultsTask?.cancel()
        resultsTask = nil
        if let analyzer { Task { await analyzer.cancelAndFinishNow() } }
        analyzer = nil
        isTranscribing = false
        releaseSession()
    }

    private func stopInput() {
        engine?.stop()
        if tapInstalled { engine?.inputNode.removeTap(onBus: 0); tapInstalled = false }
        processor?.finish()
        processor = nil
        engine = nil
        isRecording = false
        level = 0
        hasRecording = FileManager.default.fileExists(atPath: recordedFile.path())
    }

    private func releaseSession() {
        guard sessionIsActive else { return }
        sessionIsActive = false
        deactivationTask = Task { _ = try? await AVAudioSession.sharedInstance().deactivate(options: []) }
    }

    private func trace(_ stage: String) {
        let url = directory.appending(path: "voice-status.txt")
        try? "\(Date.now.formatted(.iso8601)) \(stage)".write(to: url, atomically: true, encoding: .utf8)
    }
}
