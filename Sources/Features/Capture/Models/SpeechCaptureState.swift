import AVFoundation

struct SpeechCaptureState {
  var file: AVAudioFile?
  let converter: AVAudioConverter
  var frames: Int64 = 0
  var level: Double = 0
  let sampleRate: Double
}
