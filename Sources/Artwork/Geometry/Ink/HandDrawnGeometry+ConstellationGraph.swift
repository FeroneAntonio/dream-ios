import Foundation

extension HandDrawnGeometry {
  static func constellation(recipe: DreamVisualRecipe, layer: VisualLayer) -> [RenderMark] {
    let converter = FamilyGeometry(recipe: recipe, layer: layer)
    var random = SeededRandom(seed: recipe.seed &+ layer.seedOffset)
    let noise = SeededNoise(seed: recipe.seed &+ layer.seedOffset)
    let count = min(8, max(2, layer.primitiveCount))
    var centers: [(Double, Double)] = [
      (0.29 + random.signed() * 0.04, 0.57), (0.73, 0.35 + random.signed() * 0.06),
    ]
    if count > 2 {
      centers = []
      for index in 0..<count {
        let angle = Double(index) * 2.399
        let radius = 0.13 + Double(index) * 0.035
        centers.append((0.5 + cos(angle) * radius, 0.5 + sin(angle) * radius))
      }
    }
    let ink = recipe.palette.inks[0].opacity(layer.opacity)
    var marks: [RenderMark] = []
    for index in 0..<count - 1 {
      let a = centers[index]
      let b = centers[index + 1]
      for strand in 0..<38 {
        let f = Double(strand) / 37
        let points = (0...100).map { step -> RenderPoint in
          let t = Double(step) / 100
          let arch = sin(t * Double.pi) * (0.035 + f * 0.10)
          return converter.point(a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t + arch)
        }
        marks.append(
          RenderMark(
            kind: .line, points: points, color: ink.opacity(0.28 + f * 0.3),
            width: strand % 11 == 0 ? 0.002 : 0.00065))
      }
    }
    for (index, center) in centers.enumerated() {
      let size = index == 0 ? 0.15 : 0.11
      for contour in 0..<43 {
        let t = Double(contour) / 43
        let radius = size * (0.20 + pow(t, 1.7) * 0.8)
        let points = (0...130).map { step -> RenderPoint in
          let a = Double(step) / 130 * Double.pi * 2
          let form =
            1 + 0.13 * sin(a * 3 + Double(index)) + noise.value(
              cos(a) * 2 + Double(index), sin(a) * 2) * 0.09
          let x = center.0 + cos(a) * radius * form
          let y = center.1 + sin(a) * radius * form * 1.17
          return converter.point(x, y)
        }
        marks.append(
          RenderMark(
            kind: .line, points: points, color: ink.opacity(0.55 + 0.4 * (1 - t)),
            width: contour % 9 == 0 ? 0.0026 : 0.0008, closed: true))
      }
    }
    return marks
  }
}
