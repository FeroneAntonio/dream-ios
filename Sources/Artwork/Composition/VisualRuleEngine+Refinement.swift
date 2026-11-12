import Foundation

extension VisualRuleEngine {
  static func refining(
    _ original: DreamVisualRecipe, with user: UserVisualAdjustments, newSeed: UInt64? = nil
  ) -> DreamVisualRecipe {
    var recipe = original
    recipe.userAdjustments = user
    if let newSeed {
      recipe.seed = newSeed
      var random = SeededRandom(seed: newSeed)
      for index in recipe.layers.indices {
        recipe.layers[index].anchor.x = min(
          0.88, max(0.12, recipe.layers[index].anchor.x + random.signed() * 0.07))
        recipe.layers[index].anchor.y = min(
          0.88, max(0.12, recipe.layers[index].anchor.y + random.signed() * 0.045))
        recipe.layers[index].rotation = min(
          Double.pi, max(-Double.pi, recipe.layers[index].rotation + random.signed() * 0.1))
        if [.rising, .falling].contains(recipe.layers[index].direction) {
          recipe.layers[index].rotation = min(0.3, max(-0.3, recipe.layers[index].rotation))
        }
      }
      recipe.decisions.removeAll { $0.ruleID == "user-variant" }
      recipe.decisions.append(
        VisualDecision(
          ruleID: "user-variant", source: .userChoice,
          detail: "You chose another arrangement within the same story-led structure."))
    }
    if let energy = user.energy, energy.isFinite {
      let amount = min(1, max(0, energy))
      for index in recipe.layers.indices {
        recipe.layers[index].density = 0.2 + amount * 0.7
        recipe.layers[index].turbulence = 0.1 + amount * 0.65
        recipe.layers[index].roughness = 0.15 + amount * 0.6
      }
      recipe.finish.edgeRoughness = 0.1 + amount * 0.65
      recipe.finish.grain = 0.2 + amount * 0.3
      recipe.finish.inkBleed = 0.1 + amount * 0.15
      for index in recipe.decisions.indices where recipe.decisions[index].source == .dreamyHint {
        recipe.decisions[index].overridden = true
      }
      recipe.decisions.removeAll { $0.ruleID == "user-energy" }
      recipe.decisions.append(
        VisualDecision(
          ruleID: "user-energy", source: .userChoice,
          detail: amount < 0.5
            ? "You chose a calmer visual rhythm." : "You chose a more intense visual rhythm."))
    }
    if let palette = user.palette {
      recipe.palette = .make(palette, dark: recipe.palette.background.luminance < 0.15)
      recipe.decisions.removeAll { $0.ruleID == "user-palette" }
      recipe.decisions.append(
        VisualDecision(
          ruleID: "user-palette", source: .userChoice,
          detail: "You chose the \(palette.label) colors."))
    }
    return recipe
  }
}
