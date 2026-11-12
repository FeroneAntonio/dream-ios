import Foundation

struct VisualRuleEngine {
  static func compose(
    features input: NarrativeVisualFeatures, emotionHints: [DreamEmotion] = [],
    emotionHintsTruncated: Bool = false, user: UserVisualAdjustments = .init(), seed: UInt64
  ) -> DreamVisualRecipe {
    var features = input
    let strongKinds = Set(
      NarrativeCueKind.allCases.filter { ![.light, .sceneChange].contains($0) })
    if features.cues.contains(where: { $0.source == .narrative && strongKinds.contains($0.kind) }) {
      // A model suggestion cannot outrank a literal structural cue.
      features.cues.removeAll { $0.source == .modelSuggestion }
    }
    var primary = VisualLayer(family: .chromaticHaze)
    var secondary: [VisualLayer] = []
    var layout = VisualLayout.offCenter
    var decisions: [VisualDecision] = []
    func reason(_ kind: NarrativeCueKind, _ family: VisualFamily, _ explanation: String) {
      guard let cue = features.first(kind) else { return }
      let prefix =
        cue.source == .modelSuggestion
        ? "The model suggested a visual echo of “\(cue.excerpt)”. "
        : "You described “\(cue.excerpt)”. "
      decisions.append(
        VisualDecision(
          ruleID: "narrative-\(kind.rawValue)", source: cue.source,
          evidenceExcerpt: cue.excerpt, detail: prefix + explanation, familyAffected: family))
    }
    func layer(_ family: VisualFamily, x: Double, y: Double, scale: Double, opacity: Double = 0.65)
      -> VisualLayer
    {
      VisualLayer(
        family: family, anchor: NormalizedPoint(x: x, y: y), scale: scale, opacity: opacity,
        seedOffset: UInt64(secondary.count + 101), role: .secondary)
    }
    if features.has(.branching) {
      primary.family = .branchingPaths
      primary.primitiveCount = max(2, min(5, features.first(.branching)?.count ?? 3))
      layout = .split
      reason(
        .branching, .branchingPaths, "The main lines divide into \(primary.primitiveCount) paths.")
    } else if features.has(.doors) && !features.has(.bending) {
      primary.family = .thresholdRooms
      primary.primitiveCount = min(12, max(3, features.first(.doors)?.count ?? 5))
      layout = .offCenter
      reason(.doors, .thresholdRooms, "Open frames echo the thresholds in your story.")
      if features.has(.repetition) {
        secondary.append(layer(.nestedEchoes, x: 0.73, y: 0.48, scale: 0.35, opacity: 0.25))
        reason(.repetition, .nestedEchoes, "Smaller repeating contours echo the recurrence.")
      }
    } else if features.has(.connection) && features.has(.crowd) {
      primary.family = .constellationGraph
      primary.primitiveCount = 2
      layout = .dualFocus
      secondary.append(layer(.particleField, x: 0.5, y: 0.56, scale: 0.95, opacity: 0.65))
      reason(
        .connection, .constellationGraph, "Two connected focal marks keep the meeting visible.")
      reason(.crowd, .particleField, "A surrounding field of small marks echoes the crowd.")
    } else if features.has(.falling) || features.has(.rising) || features.has(.drifting) {
      primary.family = .flowField
      layout = .verticalJourney
      primary.direction =
        features.has(.falling) ? .falling : (features.has(.rising) ? .rising : .crossing)
      primary.converges = features.has(.rescue) && features.has(.falling)
      let movement =
        features.has(.falling)
        ? NarrativeCueKind.falling : (features.has(.rising) ? .rising : .drifting)
      let movementDetail =
        primary.direction == .rising
        ? "Continuous paths travel upward through the print."
        : (primary.direction == .falling
          ? "Continuous paths descend through the print."
          : "Continuous paths cross the print like the movement you described.")
      reason(
        movement, .flowField,
        primary.converges ? "Descending paths converge toward a meeting point." : movementDetail)
      if features.has(.rescue) {
        var meeting = layer(.constellationGraph, x: 0.57, y: 0.77, scale: 0.28, opacity: 0.9)
        meeting.primitiveCount = 2
        secondary.append(meeting)
        reason(
          .rescue, .constellationGraph,
          "Connected marks echo the contact and the change you described.")
      } else if features.has(.light) {
        secondary.append(layer(.chromaticHaze, x: 0.62, y: 0.16, scale: 0.65, opacity: 0.85))
        reason(.light, .chromaticHaze, "A soft field gives the remembered light its own region.")
      }
      // Repetition, rather than ascent alone, leads the endless staircase.
      if features.has(.repetition) {
        primary.family = .nestedEchoes
        secondary = []
        layout = .verticalJourney
        decisions = []
        reason(
          .repetition, .nestedEchoes, "Nested, offset contours echo the repeated progression.")
      }
    } else if features.has(.bending) {
      primary.family = .warpedBands
      primary.rotation = -0.22
      layout = .diagonal
      reason(.bending, .warpedBands, "Bent parallel bands follow the changing streets or corridor.")
      if features.has(.fracture) {
        secondary.append(layer(.fracturedCells, x: 0.73, y: 0.67, scale: 0.67, opacity: 1))
        reason(.fracture, .fracturedCells, "Separated polygon pieces break the continuous surface.")
      }
    } else if features.has(.fracture) {
      primary.family = .fracturedCells
      layout = .split
      reason(.fracture, .fracturedCells, "Cut surfaces and gaps echo the break in the scene.")
    } else if features.has(.emptiness) {
      primary.family = .negativeVoid
      layout = .voidFocus
      primary.hasFocus = features.has(.light)
      reason(
        .emptiness, .negativeVoid,
        "Most of the print stays open rather than adding imagined objects.")
      if features.has(.light) {
        reason(.light, .negativeVoid, "A small distant focus follows the light you remembered.")
      }
    } else if features.has(.rotation) {
      primary.family = .spiralImprint
      layout = .offCenter
      reason(.rotation, .spiralImprint, "One irregular ink path curls through repeated turns.")
    } else if features.has(.repetition) {
      primary.family = .nestedEchoes
      layout = .central
      reason(.repetition, .nestedEchoes, "Nested contours echo the repetition you described.")
    } else if features.has(.simultaneous) {
      primary.family = .interferenceWaves
      layout = .dualFocus
      reason(
        .simultaneous, .interferenceWaves,
        "Two overlapping wave fields echo the simultaneous elements.")
    } else if features.has(.directions) {
      primary.family = .angularRays
      layout = .distributed
      reason(.directions, .angularRays, "Unequal rays open toward several directions.")
    } else if features.has(.crowd) {
      primary.family = .particleField
      layout = .distributed
      reason(
        .crowd, .particleField, "Many small clustered marks follow the multitude you described.")
    } else if features.has(.connection) {
      primary.family = .constellationGraph
      primary.primitiveCount = 2
      layout = .dualFocus
      reason(
        .connection, .constellationGraph, "Connected marks echo the explicitly mentioned company.")
    } else if features.has(.sceneChange) {
      primary.family = .layeredCollage
      layout = .split
      reason(
        .sceneChange, .layeredCollage, "Overlapping planes separate successive parts of the story.")
    } else {
      primary.family = .chromaticHaze
      if features.has(.blurred) {
        reason(.blurred, .chromaticHaze, "Soft edges echo the indistinct memory.")
      } else {
        decisions.append(
          VisualDecision(
            ruleID: "quiet-fallback", source: .artisticRule,
            detail:
              "Soft, open fields offer an abstract starting point for your story.",
            familyAffected: .chromaticHaze))
      }
    }
    let theme: VisualPalette
    switch primary.family {
    case .thresholdRooms, .nestedEchoes, .spiralImprint, .negativeVoid: theme = .inkPaper
    case .flowField: theme = .inkPaper
    case .constellationGraph, .interferenceWaves: theme = .inkPaper
    case .warpedBands, .angularRays, .layeredCollage: theme = .inkPaper
    case .branchingPaths, .particleField, .fracturedCells: theme = .inkPaper
    case .chromaticHaze: theme = .chromaticHaze
    }
    if primary.family == .negativeVoid { primary.anchor = NormalizedPoint(x: 0.5, y: 0.5) }
    var recipe = DreamVisualRecipe(
      seed: seed, inputFingerprint: features.inputFingerprint, layout: layout,
      layers: [primary] + secondary,
      palette: .make(
        theme, dark: primary.family == .negativeVoid),
      decisions: decisions)
    // Independent presence hints alter only minor print finish, never topology or hue.
    for emotion in DreamEmotion.allCases where emotionHints.contains(emotion) {
      switch emotion {
      case .anger: recipe.finish.edgeRoughness += 0.06
      case .apprehension: recipe.finish.grain += 0.04
      case .sadness: recipe.finish.inkBleed += 0.04
      case .confusion: recipe.finish.edgeRoughness += 0.04
      case .happiness: recipe.finish.inkBleed -= 0.03
      }
      recipe.decisions.append(
        VisualDecision(
          ruleID: "dreamy-\(emotion.rawValue)", source: .dreamyHint,
          detail:
            "DReAMy tentatively suggested \(emotion.label.lowercased())\(emotionHintsTruncated ? " in the beginning of the report" : ""); a small print-finish adjustment is an artistic response, not measured intensity."
        ))
    }
    recipe.decisions.append(
      VisualDecision(
        ruleID: "print-palette", source: .artisticRule,
        detail: "The \(theme.label) palette is a printmaking choice, not an emotional code."))
    if features.analyzedBeginningOnly {
      recipe.decisions.append(
        VisualDecision(
          ruleID: "analysis-limit", source: .modelSuggestion,
          detail: "Language-model visual cues used only the beginning of this long report."))
    }
    recipe.rendererVersion = 2
    recipe.decisions.append(VisualDecision(ruleID:"ink-graphite",source:.artisticRule,detail:"Pressure-varied ink and graphite hatching are artistic printmaking choices."))
    return refining(recipe, with: user)
  }

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
