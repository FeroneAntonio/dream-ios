import SwiftUI

struct VoiceControl: View {
  var voice: DreamVoice
  var action: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      Button(action: action) {
        VStack(spacing: 16) {
          Image(systemName: voice.isRecording ? "stop.fill" : "mic.fill")
            .font(.largeTitle).frame(width: 88, height: 88)
            .background(
              voice.isRecording ? Color.red.opacity(0.22) : Color.white.opacity(0.10), in: .circle)
          Text(
            voice.isPreparing
              ? (voice.message ?? "One moment…")
              : voice.isTranscribing
                ? "Transcribing…"
                : voice.isRecording
                  ? "Finish recording" : voice.hasRecording ? "Record again" : "Tap to record")
        }
      }
      .buttonStyle(.plain).disabled(voice.isPreparing || voice.isTranscribing)
      .accessibilityIdentifier("voiceCapture")
      if voice.isPreparing || voice.isTranscribing { ProgressView() }
      if voice.isRecording {
        Text(Duration.seconds(voice.elapsed), format: .time(pattern: .minuteSecond))
          .monospacedDigit().font(.footnote)
        ProgressView(value: voice.level).tint(.orange).frame(maxWidth: 180)
          .accessibilityLabel("Microphone level")
      }
      if let message = voice.message, !voice.isRecording {
        Text(message).font(.footnote).foregroundStyle(Color("SecondaryInk"))
          .multilineTextAlignment(.center)
      }
    }
    .padding(.vertical, 16).frame(maxWidth: .infinity)
  }
}
