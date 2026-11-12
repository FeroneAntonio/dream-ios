import ImageIO
import SwiftUI

struct RecipeArtwork: View {
  var recipe: DreamVisualRecipe
  var snapshot: URL?
  var pixels = 1080
  @State private var image: CGImage?
  @State private var failed = false

  var body: some View {
    ZStack {
      Color(
        .sRGB, red: recipe.palette.background.r, green: recipe.palette.background.g,
        blue: recipe.palette.background.b)
      if let image {
        Image(decorative: image, scale: 1).resizable().interpolation(.high).scaledToFit()
      } else if failed {
        Text("Portrait unavailable").font(.footnote).foregroundStyle(.secondary)
      }
    }
    .aspectRatio(1, contentMode: .fit)
    .accessibilityElement(children: .ignore).accessibilityLabel(recipe.accessibleDescription)
    .task(id: recipe.identity + "-\(pixels)", load)
  }
  private func load() async {
    failed = false
    image = nil
    do {
      let rendered = try await PortraitImageLoader.load(
        recipe: recipe, snapshot: snapshot, pixels: pixels)
      try Task.checkCancellation()
      image = rendered
    } catch is CancellationError {} catch { failed = true }
  }
}
