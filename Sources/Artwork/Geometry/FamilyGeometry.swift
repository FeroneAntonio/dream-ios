import Foundation

/// Bounded normalized geometry shared by iOS and the native macOS gallery.
struct FamilyGeometry {
  let recipe: DreamVisualRecipe
  let layer: VisualLayer
  var random: SeededRandom
  let noise: SeededNoise
  var marks: [RenderMark] = []

  init(recipe: DreamVisualRecipe, layer: VisualLayer) {
    self.recipe = recipe
    self.layer = layer
    random = SeededRandom(seed: recipe.seed &+ layer.seedOffset)
    noise = SeededNoise(seed: recipe.seed &+ layer.seedOffset)
  }
  var inks: [VisualRGBA] { recipe.palette.inks }
  var paper: VisualRGBA { recipe.palette.background }
  func ink(_ index: Int, opacity: Double = 1) -> VisualRGBA {
    inks[abs(index) % inks.count].opacity(opacity * layer.opacity)
  }
  func point(_ x: Double, _ y: Double) -> RenderPoint {
    let px = (x - 0.5) * layer.scale
    let py = (y - 0.5) * layer.scale
    return RenderPoint(
      layer.anchor.x + px * cos(layer.rotation) - py * sin(layer.rotation),
      layer.anchor.y + px * sin(layer.rotation) + py * cos(layer.rotation))
  }
  mutating func line(
    _ vertices: [(Double, Double)], _ color: VisualRGBA, width: Double = 0.002, closed: Bool = false
  ) {
    marks.append(
      RenderMark(
        kind: .line, points: vertices.map { point($0.0, $0.1) }, color: color,
        width: width * layer.scale, closed: closed))
  }
  mutating func polygon(_ vertices: [(Double, Double)], _ color: VisualRGBA) {
    marks.append(
      RenderMark(
        kind: .polygon, points: vertices.map { point($0.0, $0.1) }, color: color, closed: true))
  }
  mutating func dot(
    _ x: Double, _ y: Double, _ radius: Double, _ color: VisualRGBA, elongation: Double = 1
  ) {
    marks.append(
      RenderMark(
        kind: .ellipse, points: [point(x, y)], color: color, radiusX: radius * layer.scale,
        radiusY: radius * elongation * layer.scale))
  }
  mutating func glow(
    _ x: Double, _ y: Double, _ radius: Double, _ color: VisualRGBA, elongation: Double = 1
  ) {
    marks.append(
      RenderMark(
        kind: .glow, points: [point(x, y)], color: color, radiusX: radius * layer.scale,
        radiusY: radius * elongation * layer.scale))
  }
  mutating func make() -> [RenderMark] {
    switch layer.family {
    case .chromaticHaze: haze()
    case .spiralImprint: spiral()
    case .warpedBands: bands()
    case .nestedEchoes: echoes()
    case .angularRays: rays()
    case .flowField: flow()
    case .fracturedCells: cells()
    case .constellationGraph: graph()
    case .thresholdRooms: rooms()
    case .branchingPaths: branches()
    case .layeredCollage: collage()
    case .interferenceWaves: interference()
    case .negativeVoid: void()
    case .particleField: particles()
    }
    return marks
  }
}
