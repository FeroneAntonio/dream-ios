import Foundation

/// Version 1 geometry. It receives only a frozen recipe: no text, health data,
/// wall clock, global RNG, UI size, language model or dictionary iteration order.
struct ProceduralRenderEngine {
  static func makePlan(recipe: DreamVisualRecipe) throws -> RenderPlan {
    guard recipe.isValid else { throw CocoaError(.coderInvalidValue) }
    if (recipe.rendererVersion ?? 1) >= 2 { return try HandDrawnRenderer.makePlan(recipe: recipe) }
    return try makeBasePlan(recipe: recipe)
  }
  static func makeBasePlan(recipe: DreamVisualRecipe, pen: Bool = false) throws -> RenderPlan {
    guard recipe.isValid else { throw CocoaError(.coderInvalidValue) }
    var marks: [RenderMark] = []
    // Secondary texture/fields sit behind the dominant structure.
    for layer in recipe.layers.filter({ $0.role != .primary })
      + recipe.layers.filter({ $0.role == .primary })
    {
      var generator = FamilyGeometry(recipe: recipe, layer: layer)
      if recipe.rendererVersion == 3 {
        var etching = EtchingGeometry(recipe: recipe, layer: layer)
        marks += etching.make()
      } else if pen {
        switch layer.family {
        case .branchingPaths: marks += HandDrawnGeometry.branching(recipe: recipe, layer: layer)
        case .thresholdRooms: marks += HandDrawnGeometry.rooms(recipe: recipe, layer: layer)
        case .constellationGraph:
          marks += HandDrawnGeometry.constellation(recipe: recipe, layer: layer)
        case .nestedEchoes: marks += HandDrawnGeometry.echoes(recipe: recipe, layer: layer)
        default: marks += generator.make()
        }
      } else {
        marks += generator.make()
      }
    }
    let edgeNoise = SeededNoise(seed: recipe.seed ^ 0xC0FFE)
    var printed: [RenderMark] = []
    for var mark in marks {
      if mark.kind == .line || mark.kind == .polygon {
        mark.points = mark.points.map { point in
          let displacement =
            edgeNoise.value(point.x * 70, point.y * 70) * recipe.finish.edgeRoughness * 0.0015
          return RenderPoint(point.x + displacement, point.y + displacement * 0.7)
        }
      }
      if !pen && mark.kind == .line && recipe.finish.inkBleed > 0 {
        var bleed = mark
        bleed.width = mark.width + recipe.finish.inkBleed * 0.002
        bleed.color = mark.color.opacity(0.12)
        printed.append(bleed)
      }
      printed.append(mark)
    }
    marks = printed
    var random = SeededRandom(seed: recipe.seed ^ 0xD5A17)
    let ink =
      recipe.palette.background.luminance > 0.5 ? VisualRGBA(0x191A24) : VisualRGBA(0xEEE8D9)
    let count = Int(1800 + recipe.finish.grain * 5600)
    for _ in 0..<count {
      let x = random.unit()
      let y = random.unit()
      // Keep the distant focus and open center of the void visually quiet.
      let void = recipe.layers.first?.family == .negativeVoid
      if void && x > 0.2 && x < 0.8 && y > 0.28 && y < 0.7 { continue }
      let radius = 0.00025 + random.unit() * 0.001
      marks.append(
        RenderMark(
          kind: .ellipse, points: [RenderPoint(x, y)],
          color: ink.opacity(0.045 + random.unit() * 0.15), radiusX: radius, radiusY: radius))
    }
    let result = RenderPlan(background: recipe.palette.background, marks: marks)
    guard result.isFiniteAndBounded else { throw CocoaError(.coderInvalidValue) }
    return result
  }
}
