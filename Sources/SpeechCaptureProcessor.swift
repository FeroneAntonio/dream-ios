import AVFoundation
import Speech
import Synchronization

final class SpeechCaptureProcessor: Sendable {
    private let state: Mutex<SpeechCaptureState>
    private let continuation: AsyncThrowingStream<AnalyzerInput, Error>.Continuation
    private let outputFormat: AVAudioFormat

    init(inputFormat: AVAudioFormat, outputFormat: AVAudioFormat, recordingURL: URL,
         continuation: AsyncThrowingStream<AnalyzerInput, Error>.Continuation) throws {
        guard outputFormat.commonFormat == .pcmFormatInt16,
              let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else {
            throw CocoaError(.featureUnsupported)
        }
        let file = try AVAudioFile(forWriting: recordingURL, settings: inputFormat.settings,
                                  commonFormat: inputFormat.commonFormat, interleaved: inputFormat.isInterleaved)
        state = Mutex(SpeechCaptureState(file: file, converter: converter, sampleRate: inputFormat.sampleRate))
        self.continuation = continuation
        self.outputFormat = outputFormat
    }

    // The audio callback owns each incoming buffer for this synchronous call.
    // File and converter access stay under the lock; only a new converted buffer leaves it.
    func process(_ buffer: AVAudioPCMBuffer) {
        do {
            let input: AnalyzerInput? = try state.withLock { state in
                guard let file = state.file else { return nil }
                try file.write(from: buffer)
                state.frames += Int64(buffer.frameLength)
                if let channel = buffer.floatChannelData?[0], buffer.frameLength > 0 {
                    var sum: Float = 0
                    for i in 0..<Int(buffer.frameLength) { sum += channel[i] * channel[i] }
                    let rms = sqrt(Double(sum) / Double(buffer.frameLength))
                    state.level = max(0, min(1, (20 * log10(max(rms, 0.00001)) + 60) / 60))
                }
                let capacity = AVAudioFrameCount(ceil(Double(buffer.frameLength) * outputFormat.sampleRate / buffer.format.sampleRate) + 1)
                guard let converted = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: capacity) else { return nil }
                var supplied = false
                var conversionError: NSError?
                let status = state.converter.convert(to: converted, error: &conversionError) { _, result in
                    if supplied { result.pointee = .noDataNow; return nil }
                    supplied = true
                    result.pointee = .haveData
                    return buffer
                }
                if let conversionError { throw conversionError }
                guard status != .error, converted.frameLength > 0 else { return nil }
                return AnalyzerInput(buffer: converted)
            }
            if let input { continuation.yield(input) }
        } catch { continuation.finish(throwing: error) }
    }

    func meter() -> (level: Double, elapsed: Double) {
        state.withLock { ($0.level, Double($0.frames) / $0.sampleRate) }
    }

    func finish() {
        state.withLock { $0.file = nil }
        continuation.finish()
    }
}
