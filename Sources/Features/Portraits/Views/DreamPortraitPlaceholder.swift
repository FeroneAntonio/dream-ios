import SwiftUI

struct DreamPortraitPlaceholder: View {
  private static let recipe = VisualRuleEngine.compose(
    features: NarrativeVisualAnalyzer.local(""), seed: 91)
  var body: some View { RecipeArtwork(recipe: Self.recipe, pixels: 780) }
}
