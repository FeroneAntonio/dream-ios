import Foundation

extension HandDrawnGeometry {
  static func echoes(recipe: DreamVisualRecipe, layer: VisualLayer) -> [RenderMark] {
    let converter = FamilyGeometry(recipe: recipe, layer: layer)
    let noise = SeededNoise(seed: recipe.seed &+ layer.seedOffset)
    let ink = recipe.palette.inks[0].opacity(layer.opacity)
    var marks: [RenderMark] = []
    let count = 35 + Int(layer.density * 25)
    for index in 0..<count {
      let t = Double(index) / Double(count - 1)
      let radius = 0.025 + pow(t, 1.15) * 0.66
      let cx = 0.43 + sin(t * 3.8) * 0.095
      let cy = 0.34 + t * 0.18
      let points = (0...190).map { step -> RenderPoint in
        let a = Double(step) / 190 * Double.pi * 2
        let c = cos(a)
        let s = sin(a)
        let form = 1 + 0.08 * sin(a * 3 + t * 4) + noise.value(c * 3 + t, s * 3) * 0.035
        let x = (c >= 0 ? 1.0 : -1.0) * pow(abs(c), 0.72)
        let y = (s >= 0 ? 1.0 : -1.0) * pow(abs(s), 0.72)
        return converter.point(cx + x * radius * form, cy + y * radius * form)
      }
      marks.append(
        RenderMark(
          kind: .line, points: points, color: ink.opacity(0.75),
          width: index % 9 == 0 ? 0.0033 : 0.0011, closed: true))
    }
    return marks
  }
}
