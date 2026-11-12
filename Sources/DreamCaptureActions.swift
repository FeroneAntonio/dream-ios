import SwiftUI

struct DreamCaptureActions: View {
  var onRecord: () -> Void
  var onWrite: () -> Void
  var body: some View {
    ViewThatFits(in: .horizontal) {
      HStack(spacing: 12) {
        record
        write
      }
      VStack(spacing: 12) {
        record
        write
      }
    }.controlSize(.large).frame(maxWidth: .infinity).padding(.vertical, 16)
  }
  private var record: some View {
    Button("Record", systemImage: "mic", action: onRecord)
      .buttonStyle(.borderedProminent).tint(.white).foregroundStyle(.black)
      .accessibilityIdentifier("newVoiceDream")
  }
  private var write: some View {
    Button("Write", systemImage: "square.and.pencil", action: onWrite)
      .buttonStyle(.bordered).tint(.white).accessibilityIdentifier("newTextDream")
  }
}
