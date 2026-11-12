import SwiftUI

struct DreamReflectionSection: View {
  var entry: DreamEntry
  var isCreating: Bool
  var hasStatus: Bool
  var onInterpret: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      if !entry.reflection.isEmpty {
        Divider()
        Text(entry.usedAI ? "A possible meaning" : "A moment to reflect")
          .font(.title2).fontDesign(.serif)
        Text(entry.reflection)
        Text(entry.question).font(.title3).fontDesign(.serif)
        if !entry.usedAI {
          Text("A reflection prompt or your own words, rather than an AI interpretation.")
            .font(.footnote).foregroundStyle(Color("SecondaryInk"))
        }
      } else if !entry.text.isEmpty {
        Button("Interpret dream", systemImage: "text.bubble", action: onInterpret)
          .buttonStyle(.bordered).controlSize(.large).disabled(isCreating)
      }
      if isCreating { ProgressView("Finding a possible meaning…") }
      if hasStatus {
        Text("A possibility to explore. The meaning is yours.")
          .font(.footnote).foregroundStyle(Color("SecondaryInk"))
      }
    }
  }
}
