import SwiftUI

struct DreamCaptureEditor: View {
  var mode: DreamCaptureMode?
  @Bindable var composer: DreamComposer
  var voice: DreamVoice
  var writing: FocusState<Bool>.Binding
  var onToggleVoice: () -> Void
  var onOpenSettings: () -> Void

  var body: some View {
    VStack(spacing: 20) {
      if mode == .voice {
        VoiceControl(voice: voice, action: onToggleVoice).disabled(composer.isCreating)
        if voice.needsSettings { Button("Open Settings", action: onOpenSettings) }
      } else {
        Text("What did you dream?").font(.title2).fontDesign(.serif)
          .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 24)
      }
      TextField("Write what you remember…", text: $composer.text, axis: .vertical)
        .font(.title3).lineLimit(6...16).focused(writing)
        .disabled(
          voice.isRecording || voice.isPreparing || voice.isTranscribing
            || composer.isCreating
        )
        .accessibilityIdentifier("dreamText")
      if composer.restoredDraft {
        Text("Draft restored").font(.footnote).foregroundStyle(Color("SecondaryInk"))
      }
    }
  }
}
