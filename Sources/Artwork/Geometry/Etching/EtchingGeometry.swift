import Foundation

/// Renderer 3 builds a complete etched composition from a frozen layer and seed.
struct EtchingGeometry {
  var drawing: FamilyGeometry
  var random: SeededRandom
  let noise: SeededNoise
  let study: Int
  let phase: Double

  init(recipe: DreamVisualRecipe, layer: VisualLayer) {
    drawing = FamilyGeometry(recipe: recipe, layer: layer)
    let seed = recipe.seed &+ layer.seedOffset
    random = SeededRandom(seed: seed ^ 0xE7C41)
    noise = SeededNoise(seed: seed)
    study = Int(random.next() % 6)
    phase = random.unit() * Double.pi * 2
  }

  var layer: VisualLayer { drawing.layer }
  var density: Double { layer.density }
  func ink(_ index: Int = 0, _ opacity: Double = 1) -> VisualRGBA {
    var color = drawing.ink(index, opacity: opacity)
    if drawing.paper.luminance < 0.2 && color.luminance < 0.4 {
      color.r = color.r * 0.5 + 0.46
      color.g = color.g * 0.5 + 0.44
      color.b = color.b * 0.5 + 0.40
    }
    return color
  }

  mutating func make() -> [RenderMark] {
    switch layer.family {
    case .branchingPaths: branching()
    case .thresholdRooms: architecture()
    case .constellationGraph: constellation()
    case .nestedEchoes: echoes()
    case .flowField: currents()
    case .spiralImprint: spirals()
    case .warpedBands: wovenBands()
    case .angularRays: rays()
    case .fracturedCells: fragments()
    case .particleField: particles()
    case .layeredCollage: collage()
    case .interferenceWaves: interference()
    case .negativeVoid: void()
    case .chromaticHaze: haze()
    }
    return drawing.marks
  }

  /// One organic volume: contours drift and deform rather than sharing one center.
  mutating func volume(
    center: (Double, Double), radius: Double, aspect: Double = 1,
    rings: Int = 44, color: Int = 0, opening: Double = 0
  ) {
    let firstMark = drawing.marks.count
    let lobes = 2 + study % 4
    let tilt = random.signed() * 0.6
    for ring in 0..<rings {
      let fraction = Double(ring) / Double(max(1, rings - 1))
      let size = radius * (0.06 + pow(fraction, 1.5) * 0.94)
      let drift = radius * 0.30 * sin(fraction * 2.6 + phase)
      var points: [(Double, Double)] = []
      for step in 0...144 {
        let angle = opening + Double(step) / 144 * (Double.pi * 2 - opening * 2)
        let ripple =
          1 + sin(angle * Double(lobes) + phase + fraction * 2) * 0.12
          + noise.value(cos(angle) * 3 + fraction, sin(angle) * 3) * 0.09
        let x = cos(angle) * size * ripple
        let y = sin(angle) * size * ripple * aspect
        points.append(
          (
            center.0 + drift * (1 - fraction) + x * cos(tilt) - y * sin(tilt),
            center.1 + y * cos(tilt) + x * sin(tilt)
          ))
      }
      drawing.line(
        points, ink(color, 0.24 + 0.58 * fraction),
        width: ring % 13 == 0 ? 0.0022 : 0.00065,
        closed: opening == 0)
    }
    if opening == 0, let outline = drawing.marks.last {
      // Paper knockout separates the foreground volume from crossing ribbons.
      drawing.marks.insert(
        RenderMark(
          kind: .polygon, points: outline.points,
          color: drawing.paper, closed: true), at: firstMark)
      if study % 3 == 0, firstMark + 1 < drawing.marks.count {
        let core = drawing.marks[min(drawing.marks.count - 1, firstMark + 1 + rings / 5)]
        drawing.marks.insert(
          RenderMark(
            kind: .polygon, points: core.points,
            color: ink(0, 0.85), closed: true), at: firstMark + 1)
      }
    }
  }

  static func cubic(
    _ a: (Double, Double), _ b: (Double, Double), _ c: (Double, Double),
    _ d: (Double, Double), _ t: Double
  ) -> (Double, Double) {
    let u = 1 - t
    return (
      u * u * u * a.0 + 3 * u * u * t * b.0 + 3 * u * t * t * c.0 + t * t * t * d.0,
      u * u * u * a.1 + 3 * u * u * t * b.1 + 3 * u * t * t * c.1 + t * t * t * d.1
    )
  }

  /// A ribbon carries its own varying cross-section and a coherent etched grain.
  mutating func ribbon(
    from start: (Double, Double), to end: (Double, Double),
    bend: Double, width: Double, strands: Int = 42, color: Int = 0
  ) {
    let dx = end.0 - start.0
    let dy = end.1 - start.1
    let distance = max(0.01, hypot(dx, dy))
    let normal = (-dy / distance, dx / distance)
    let controlA = (
      start.0 + dx * 0.25 + normal.0 * bend,
      start.1 + dy * 0.25 + normal.1 * bend
    )
    let controlB = (
      start.0 + dx * 0.72 - normal.0 * bend * 0.7,
      start.1 + dy * 0.72 - normal.1 * bend * 0.7
    )
    for strand in 0..<strands {
      let across = Double(strand) / Double(max(1, strands - 1)) - 0.5
      var points: [(Double, Double)] = []
      for step in 0...144 {
        let t = Double(step) / 144
        let p = Self.cubic(start, controlA, controlB, end, t)
        let tangentX =
          3 * (1 - t) * (1 - t) * (controlA.0 - start.0)
          + 6 * (1 - t) * t * (controlB.0 - controlA.0) + 3 * t * t * (end.0 - controlB.0)
        let tangentY =
          3 * (1 - t) * (1 - t) * (controlA.1 - start.1)
          + 6 * (1 - t) * t * (controlB.1 - controlA.1) + 3 * t * t * (end.1 - controlB.1)
        let length = max(0.001, hypot(tangentX, tangentY))
        let envelope = pow(max(0, sin(t * Double.pi)), 0.6 + Double(study) * 0.10)
        let offset =
          across * width * envelope
          + noise.value(t * 5, Double(strand) * 0.025) * 0.004 * envelope
        points.append((p.0 - tangentY / length * offset, p.1 + tangentX / length * offset))
      }
      let edge = strand == 0 || strand == strands - 1
      drawing.line(
        points, ink(color, edge ? 0.92 : 0.24 + abs(across) * 0.7),
        width: edge ? 0.0024 : 0.0007)
    }
  }
}
