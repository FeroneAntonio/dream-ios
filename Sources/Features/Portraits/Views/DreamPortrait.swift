import SwiftUI

struct DreamPortrait: View {
  var entry: DreamEntry
  var pixels = 1080
  var animates = true
  @Environment(DreamStore.self) private var store

  var body: some View {
    Group {
      if let recipe = entry.visualRecipe {
        RecipeArtwork(recipe: recipe, snapshot: store.snapshotURL(for: entry), pixels: pixels)
      } else {
        let old =
          entry.legacyPortrait
          ?? LegacyPortrait(
            seed: entry.seed, feeling: entry.feeling, intensity: entry.intensity, motif: entry.motif
          )
        DreamArtwork(
          seed: old.seed, feeling: old.feeling, intensity: old.intensity, heartRate: nil,
          motif: old.motif, animates: animates)
      }
    }.aspectRatio(1, contentMode: .fit)
  }
}
