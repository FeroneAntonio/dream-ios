import AVFoundation
import Speech
import Testing
@testable import DREAM

struct SpeechPipelineTests {
    @Test func partialWordsReplaceEachOtherInsteadOfDuplicating() {
        var transcript = DreamTranscript()
        #expect(transcript.accept(start: 0, text: "I was", isFinal: false) == "I was")
        #expect(transcript.accept(start: 0, text: "I was walking", isFinal: false) == "I was walking")
        #expect(transcript.accept(start: 0, text: "I was walking.", isFinal: true) == "I was walking.")
        #expect(transcript.accept(start: 2, text: "Through a", isFinal: false) == "I was walking. Through a")
        #expect(transcript.accept(start: 2, text: "Through a garden.", isFinal: true) == "I was walking. Through a garden.")
    }

    @Test @MainActor func microphoneFramesAreRecordedAndConvertedForSpeech() async throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let inputFormat = try #require(AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 1, interleaved: false))
        let outputFormat = try #require(AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: false))
        let buffer = try #require(AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: 4800))
        buffer.frameLength = 4800
        let channel = try #require(buffer.floatChannelData?[0])
        for i in 0..<4800 { channel[i] = Float(sin(Double(i) * 2 * .pi * 440 / 48000) * 0.25) }
        let stream = AsyncThrowingStream<AnalyzerInput, Error>.makeStream()
        let recording = directory.appending(path: "test.caf")
        let processor = try SpeechCaptureProcessor(inputFormat: inputFormat, outputFormat: outputFormat,
                                                   recordingURL: recording, continuation: stream.continuation)
        processor.process(buffer)
        #expect(abs(processor.meter().elapsed - 0.1) < 0.001)
        #expect(processor.meter().level > 0)
        processor.finish()
        let file = try AVAudioFile(forReading: recording)
        #expect(file.length == 4800)
        var iterator = stream.stream.makeAsyncIterator()
        let converted = try #require(try await iterator.next())
        #expect(converted.bufferFormat.sampleRate == 16000)
        #expect(converted.bufferDuration.seconds > 0)
    }
}
