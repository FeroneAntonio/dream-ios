import SwiftUI

struct PortraitExplanation: View {
  var recipe: DreamVisualRecipe
  var usesEarlierText: Bool
  var onRecreate: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Why this drawing?").font(.headline).fontDesign(.serif)
      Text(recipe.why).font(.subheadline)
      if usesEarlierText {
        Text("This portrait belongs to an earlier version of your story.").font(.footnote)
          .foregroundStyle(.secondary)
        Button("Recreate portrait from edited dream", action: onRecreate).frame(
          minHeight: 44)
      }
    }.accessibilityIdentifier("whyThisDrawing")
  }
}
