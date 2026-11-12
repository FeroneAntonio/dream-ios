import SwiftUI

struct InterpretDreamButton: View {
  var isCreating: Bool
  var canInterpret: Bool
  var onInterpret: () -> Void

  var body: some View {
    Button(action: onInterpret) {
      HStack {
        if isCreating { ProgressView().tint(.black) }
        Text(isCreating ? "Interpreting…" : "Interpret dream")
      }
    }
    .buttonStyle(.borderedProminent).tint(.white).foregroundStyle(.black)
    .controlSize(.large).frame(maxWidth: .infinity).padding(.vertical, 16)
    .disabled(!canInterpret || isCreating).accessibilityIdentifier("createDream")
  }
}
