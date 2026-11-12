import Foundation

extension HandDrawnGeometry {
  static func rooms(recipe: DreamVisualRecipe, layer: VisualLayer) -> [RenderMark] {
    let converter = FamilyGeometry(recipe: recipe, layer: layer)
    let noise = SeededNoise(seed: recipe.seed &+ layer.seedOffset)
    let count = max(3, min(12, layer.primitiveCount))
    let ink = recipe.palette.inks[0].opacity(layer.opacity)
    var marks: [RenderMark] = []
    var previous: [RenderPoint]?
    for index in 0..<count {
      let t = Double(index) / Double(count)
      let radius = 0.46 * pow(1 - t, 0.8) + 0.045
      let cx = 0.46 + sin(t * 4.8) * 0.10
      let cy = 0.5 - t * 0.13
      let slant = 0.07 * cos(t * 3)
      let corners: [(Double, Double)] = [
        (cx - radius * 0.85, cy + radius), (cx - radius, cy - radius * 0.91 + slant),
        (cx + radius * 0.88, cy - radius), (cx + radius, cy + radius * 0.87),
      ]
      var points: [RenderPoint] = []
      for edge in 0..<3 {
        let a = corners[edge]
        let b = corners[edge + 1]
        for step in 0...35 {
          let p = Double(step) / 35
          let warp = noise.value(p * 3, Double(index) * 0.3) * 0.008
          points.append(
            converter.point(a.0 + (b.0 - a.0) * p + warp, a.1 + (b.1 - a.1) * p + warp * 0.7))
        }
      }
      if let previous, index % 2 == 1 {
        let wall = [
          previous[previous.count / 3], previous.last!, points.last!, points[points.count / 3],
        ]
        marks.append(
          RenderMark(
            kind: .polygon, points: wall, color: ink.opacity(0.22 + 0.07 * Double(index % 3)),
            closed: true))
      }
      marks.append(
        RenderMark(kind: .line, points: points, color: ink, width: 0.0037 * (1 - t * 0.65)))
      previous = points
    }
    return marks
  }
}
