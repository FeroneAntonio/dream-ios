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

  mutating func haze() {
    // Elliptic, feathered color fields rather than a stroked radial loop.
    for index in 0..<5 {
      let x = 0.18 + random.unit() * 0.64
      let y = 0.13 + random.unit() * 0.72
      glow(
        x, y, 0.23 + random.unit() * 0.21, ink(index, opacity: 0.85),
        elongation: 0.65 + random.unit() * 0.6)
    }
    for index in 0..<16 {
      let y = 0.1 + Double(index) * 0.05
      var top: [(Double, Double)] = []
      var bottom: [(Double, Double)] = []
      for step in 0...64 {
        let x = Double(step) / 64
        let warp = noise.fbm(x * 2.2, y * 3) * 0.16
        top.append((x, y + warp))
        bottom.append((x, y + 0.012 + warp))
      }
      polygon(top + bottom.reversed(), ink(index, opacity: 0.055))
    }
  }

  mutating func spiral() {
    let turns = 3.3
    let count = 680
    var outer: [(Double, Double)] = []
    var inner: [(Double, Double)] = []
    let cx = 0.46 + random.signed() * 0.035
    let cy = 0.48
    for index in 0...count {
      let t = Double(index) / Double(count)
      let angle = t * turns * 2 * Double.pi - 0.7
      let radius = 0.018 + t * 0.45 + noise.value(t * 7, 0) * 0.009 * layer.roughness
      let width = (0.018 + 0.009 * sin(t * 7 + 1)) * (0.7 + layer.density * 0.6)
      outer.append((cx + cos(angle) * (radius + width), cy + sin(angle) * (radius + width)))
      inner.append((cx + cos(angle) * (radius - width), cy + sin(angle) * (radius - width)))
    }
    polygon(outer + inner.reversed(), ink(0))
  }

  mutating func bands() {
    let count = 16 + Int(layer.density * 14)
    func bend(_ x: Double, _ y: Double) -> Double {
      x + sin(y * 7.4 + x * 2.3) * 0.075 + noise.fbm(x * 2, y * 2.8) * layer.turbulence * 0.2
    }
    for index in -4...count + 3 {
      let x = Double(index) / Double(count)
      let width = 0.5 / Double(count)
      var left: [(Double, Double)] = []
      var right: [(Double, Double)] = []
      for step in 0...100 {
        let y = Double(step) / 100 * 1.2 - 0.1
        left.append((bend(x, y), y))
        right.append((bend(x + width, y), y))
      }
      polygon(left + right.reversed(), ink(index))
    }
  }

  mutating func echoes() {
    let count = 22 + Int(layer.density * 35)
    for index in 0..<count {
      let t = Double(index) / Double(count)
      let radius = 0.035 + t * 0.56
      var vertices: [(Double, Double)] = []
      for step in 0...200 {
        let angle = Double(step) / 200 * 2 * Double.pi
        // Superelliptic, offset contours: rectilinear landings with soft corners.
        let c = cos(angle)
        let s = sin(angle)
        let sx = (c >= 0 ? 1.0 : -1.0) * pow(abs(c), 0.52)
        let sy = (s >= 0 ? 1.0 : -1.0) * pow(abs(s), 0.52)
        let rough = noise.value(angle * 2, Double(index) * 0.12) * 0.008 * layer.roughness
        let cx = 0.49 + sin(t * 3.7) * 0.055
        let cy = 0.36 + t * 0.16
        vertices.append((cx + sx * (radius + rough), cy + sy * (radius * 0.93 + rough)))
      }
      line(
        vertices, ink(index % 9 == 0 ? 1 : 0, opacity: 0.8), width: index % 8 == 0 ? 0.006 : 0.0018,
        closed: true)
    }
  }

  mutating func rays() {
    let focus = (0.27, 0.79)
    let count = 20 + Int(layer.density * 24)
    for index in 0..<count {
      let a = -Double.pi * 0.96 + Double(index) / Double(count) * Double.pi * 1.1
      let b = a + 0.008 + random.unit() * 0.038
      let r = 0.5 + random.unit() * 0.8
      polygon(
        [
          focus, (focus.0 + cos(a) * r, focus.1 + sin(a) * r),
          (focus.0 + cos(b) * r, focus.1 + sin(b) * r),
        ], ink(index, opacity: 0.9))
      if index % 3 == 0 {
        line(
          [focus, (focus.0 + cos(b) * r, focus.1 + sin(b) * r)], ink(0, opacity: 0.5), width: 0.001)
      }
    }
  }

  mutating func flow() {
    let count = 70 + Int(layer.density * 100)
    let upward = layer.direction == .rising
    let horizontal = layer.direction == .crossing || layer.direction == .drifting
    for index in 0..<count {
      let fraction = Double(index) / Double(count - 1)
      var x = horizontal ? -0.03 : 0.02 + fraction * 0.96
      var y = horizontal ? 0.02 + fraction * 0.96 : (upward ? 1.03 : -0.03)
      var vertices: [(Double, Double)] = [(x, y)]
      for _ in 0..<240 {
        if layer.converges && y >= 0.758 {
          vertices.append((0.57, 0.77))
          break
        }
        let epsilon = 0.007
        let dx =
          (noise.fbm(x * 2, (y + epsilon) * 2) - noise.fbm(x * 2, (y - epsilon) * 2))
          / (epsilon * 4)
        let dy =
          -(noise.fbm((x + epsilon) * 2, y * 2) - noise.fbm((x - epsilon) * 2, y * 2))
          / (epsilon * 4)
        var vx = dx * (0.12 + layer.turbulence * 0.3)
        var vy = (upward ? -1.0 : 1.0) + dy * 0.16
        if horizontal {
          vx = 1 + dx * 0.16
          vy = dy * (0.12 + layer.turbulence * 0.3)
        }
        if layer.converges {
          let tx = 0.57 - x
          let ty = 0.77 - y
          if hypot(tx, ty) < 0.018 { break }
          // Taper curl toward the meeting point and keep descent
          // monotonic; an equilibrium must not trap hundreds of points.
          vx = tx * 2.3 + vx * max(0, ty) * 0.1
          vy = max(0.04, ty * 1.5)
        }
        let length = max(0.001, hypot(vx, vy))
        x += vx / length * 0.006
        y += vy / length * 0.006
        vertices.append((x, y))
        if y < -0.06 || y > 1.06 || x < -0.08 || x > 1.08 { break }
      }
      let color = ink(index / 18, opacity: 0.55 + fraction * 0.35)
      line(vertices, color, width: index % 11 == 0 ? 0.006 : 0.0016)
    }
  }

  mutating func cells() {
    let count = 18 + Int(layer.density * 28)
    let sites = (0..<count).map { _ in (0.06 + random.unit() * 0.88, 0.06 + random.unit() * 0.88) }
    for index in sites.indices {
      let site = sites[index]
      var cell: [(Double, Double)] = [(0, 0), (1, 0), (1, 1), (0, 1)]
      for other in sites.indices where other != index {
        let q = sites[other]
        let nx = q.0 - site.0
        let ny = q.1 - site.1
        let limit = (q.0 * q.0 + q.1 * q.1 - site.0 * site.0 - site.1 * site.1) * 0.5
        var clipped: [(Double, Double)] = []
        guard !cell.isEmpty else { break }
        for i in cell.indices {
          let a = cell[i]
          let b = cell[(i + 1) % cell.count]
          let da = a.0 * nx + a.1 * ny - limit
          let db = b.0 * nx + b.1 * ny - limit
          if da <= 0 { clipped.append(a) }
          if (da <= 0) != (db <= 0) {
            let t = da / (da - db)
            clipped.append((a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t))
          }
        }
        cell = clipped
      }
      let shiftX = random.signed() * 0.009
      let shiftY = random.signed() * 0.009
      let polygonPoints = cell.map {
        (site.0 + ($0.0 - site.0) * 0.91 + shiftX, site.1 + ($0.1 - site.1) * 0.91 + shiftY)
      }
      polygon(polygonPoints, ink(index, opacity: 0.7 + random.unit() * 0.3))
      if index % 3 == 0 { line(polygonPoints, paper.opacity(0.65), width: 0.001, closed: true) }
    }
  }

  mutating func graph() {
    let count = max(2, min(8, layer.primitiveCount))
    var nodes: [(Double, Double)] =
      count == 2
      ? [
        (0.26 + random.signed() * 0.055, 0.49 + random.signed() * 0.065),
        (0.72 + random.signed() * 0.055, 0.4 + random.signed() * 0.065),
      ] : (0..<count).map { _ in (0.15 + random.unit() * 0.7, 0.18 + random.unit() * 0.64) }
    // Bounded spring/repulsion relaxation. Two named participants retain two foci.
    if count > 2 {
      for _ in 0..<60 {
        let before = nodes
        for i in nodes.indices {
          var fx = 0.0
          var fy = 0.0
          for j in nodes.indices where i != j {
            let dx = before[i].0 - before[j].0
            let dy = before[i].1 - before[j].1
            let d2 = max(0.005, dx * dx + dy * dy)
            fx += dx * (0.0015 / d2 - 0.012)
            fy += dy * (0.0015 / d2 - 0.012)
          }
          nodes[i] = (
            min(0.84, max(0.16, before[i].0 + fx)), min(0.84, max(0.16, before[i].1 + fy))
          )
        }
      }
    }
    for index in 0..<count - 1 {
      let a = nodes[index]
      let b = nodes[index + 1]
      for strand in 0..<12 {
        var vertices: [(Double, Double)] = []
        for step in 0...70 {
          let t = Double(step) / 70
          let offset = sin(t * Double.pi) * (0.035 + Double(strand) * 0.009)
          vertices.append((a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t + offset))
        }
        line(vertices, ink(strand % 2, opacity: 0.65), width: strand % 5 == 0 ? 0.004 : 0.0013)
      }
    }
    for index in nodes.indices {
      let node = nodes[index]
      let radius = index == 0 ? 0.074 : 0.054
      dot(node.0, node.1, radius + 0.012, paper.opacity(layer.opacity))
      dot(node.0, node.1, radius, ink(index == 0 ? 3 : 1))
      for ring in 0..<5 {
        let r = radius + 0.02 + Double(ring) * 0.006
        let points = (0...100).map { step -> (Double, Double) in
          let a = Double(step) / 100 * Double.pi * 2
          return (node.0 + cos(a) * r, node.1 + sin(a) * r)
        }
        line(points, ink(index, opacity: 0.7), width: 0.0012, closed: true)
      }
    }
  }

  mutating func rooms() {
    let count = max(3, min(12, layer.primitiveCount))
    for index in 0..<count {
      let t = Double(index) / Double(count)
      let width = 0.88 * (1 - t * 0.82)
      let height = 0.91 * (1 - t * 0.75)
      let cx = 0.46 + t * 0.11
      let cy = 0.51 - t * 0.09
      let skew = 0.09 * (1 - t)
      let rough = 0.005 * layer.roughness
      let left = cx - width / 2
      let right = cx + width / 2
      let top = cy - height / 2
      let bottom = cy + height / 2
      polygon(
        [
          (right, top), (right + 0.027, bottom - 0.02), (right - 0.014, bottom),
          (right - 0.02, top + 0.02),
        ], ink(1, opacity: 0.15))
      var vertices: [(Double, Double)] = []
      for (a, b) in [
        ((left, bottom), (left - skew, top + skew)), ((left - skew, top + skew), (right, top)),
        ((right, top), (right, bottom)),
      ] {
        for step in 0...45 {
          let f = Double(step) / 45
          let jitter = noise.value(f * 4, Double(index)) * rough
          vertices.append((a.0 + (b.0 - a.0) * f + jitter, a.1 + (b.1 - a.1) * f + jitter))
        }
      }
      line(vertices, ink(0), width: 0.012 * (1 - t * 0.75))
      line([(left, bottom), (right, bottom)], ink(2, opacity: 0.7), width: 0.003)
    }
  }

  mutating func branches() {
    let count = min(5, max(2, layer.primitiveCount))
    let root = (0.49, 0.94)
    let junction = (0.49, 0.69)
    line([root, junction], ink(3), width: 0.028)
    for index in 0..<count {
      let f = Double(index) / Double(count - 1)
      let end = (0.08 + f * 0.84, 0.09 + abs(f - 0.5) * 0.16)
      branch(from: junction, to: end, width: 0.018, depth: 3, color: index)
    }
  }
  mutating func branch(
    from a: (Double, Double), to b: (Double, Double), width: Double, depth: Int, color: Int
  ) {
    var vertices: [(Double, Double)] = []
    let bend = random.signed() * 0.055
    for step in 0...50 {
      let t = Double(step) / 50
      let dx =
        sin(t * Double.pi) * bend + noise.value(t * 4, Double(depth)) * 0.003 * layer.roughness
      vertices.append((a.0 + (b.0 - a.0) * t + dx, a.1 + (b.1 - a.1) * t))
    }
    if width > 0.004 {
      var left: [(Double, Double)] = []
      var right: [(Double, Double)] = []
      for index in vertices.indices {
        let previous = vertices[max(0, index - 1)]
        let next = vertices[min(vertices.count - 1, index + 1)]
        let dx = next.0 - previous.0
        let dy = next.1 - previous.1
        let length = max(0.0001, hypot(dx, dy))
        let t = Double(index) / Double(vertices.count - 1)
        let radius =
          width * 0.5 * (1 - t * 0.5)
          * (1 + noise.value(t * 6, Double(color)) * layer.roughness * 0.3)
        left.append(
          (vertices[index].0 - dy / length * radius, vertices[index].1 + dx / length * radius))
        right.append(
          (vertices[index].0 + dy / length * radius, vertices[index].1 - dx / length * radius))
      }
      polygon(left + right.reversed(), ink(color, opacity: 0.95))
    } else {
      line(vertices, ink(color, opacity: 0.95), width: width)
    }
    guard depth > 0 else { return }
    for side in [-1.0, 1.0] {
      let t = 0.48 + random.unit() * 0.24
      let start = (a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t)
      let finish = (
        min(0.95, max(0.05, start.0 + side * (0.05 + Double(depth) * 0.025))),
        min(0.9, max(0.04, b.1 + 0.04 + random.unit() * 0.06))
      )
      branch(from: start, to: finish, width: width * 0.46, depth: depth - 1, color: color)
    }
  }

  mutating func collage() {
    for index in 0..<4 {
      let x = Double(index) * 0.25 - 0.08
      var upper: [(Double, Double)] = []
      var lower: [(Double, Double)] = []
      for step in 0...70 {
        let y = Double(step) / 70 * 1.12 - 0.06
        let tear = noise.value(y * 12, Double(index)) * 0.008
        upper.append((x + y * 0.18 + tear, y))
        lower.append((x + 0.34 + y * 0.06 + tear, y))
      }
      polygon(upper + lower.reversed(), ink(index, opacity: 0.9))
      line(upper, paper.opacity(0.65), width: 0.002)
    }
  }

  mutating func interference() {
    let grid = 76
    func field(_ x: Double, _ y: Double) -> Double {
      let d1 = hypot(x - 0.28, y - 0.42)
      let d2 = hypot(x - 0.74, y - 0.55)
      return sin(d1 * 45 + noise.value(x * 2, y * 2) * 0.9) + sin(d2 * 39)
    }
    for (levelIndex, level) in [-1.1, -0.4, 0.35, 1.1].enumerated() {
      for iy in 0..<grid {
        for ix in 0..<grid {
          let x = Double(ix) / Double(grid)
          let y = Double(iy) / Double(grid)
          let d = 1 / Double(grid)
          let corners = [(x, y), (x + d, y), (x + d, y + d), (x, y + d)]
          let values = corners.map { field($0.0, $0.1) - level }
          var crossings: [(Double, Double)] = []
          for edge in 0..<4 {
            let next = (edge + 1) % 4
            let va = values[edge]
            let vb = values[next]
            if (va < 0) != (vb < 0) {
              let t = va / (va - vb)
              let a = corners[edge]
              let b = corners[next]
              crossings.append((a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t))
            }
          }
          if crossings.count >= 2 {
            line(Array(crossings.prefix(2)), ink(levelIndex, opacity: 0.85), width: 0.0025)
          }
          if crossings.count == 4 {
            line(Array(crossings.suffix(2)), ink(levelIndex, opacity: 0.85), width: 0.0025)
          }
        }
      }
    }
  }

  mutating func void() {
    // No figurative silhouette: a large unmarked region, rough peripheral arcs,
    // and one small off-center light. Empty space remains the dominant shape.
    let focus = (0.76, 0.25)
    for index in 0..<25 {
      let t = Double(index) / 25
      var vertices: [(Double, Double)] = []
      for step in 0...100 {
        let a = Double(step) / 100 * 1.65 + 0.2
        let radius = 0.67 + t * 0.21 + noise.value(a * 3, t * 5) * 0.007
        vertices.append((0.63 - cos(a) * radius, 0.24 + sin(a) * radius))
      }
      line(vertices, ink(index % 2, opacity: 0.35 * (1 - t)), width: 0.002)
    }
    guard layer.hasFocus else { return }
    glow(focus.0, focus.1, 0.17, ink(1, opacity: 0.22))
    glow(focus.0, focus.1, 0.065, ink(2, opacity: 0.7))
    dot(focus.0, focus.1, 0.006, ink(0))
  }

  mutating func particles() {
    let target = 650 + Int(layer.density * 650)
    let minDistance = 0.012
    var buckets: [Int: [(Double, Double)]] = [:]
    var accepted = 0
    for _ in 0..<8000 {
      guard accepted < target else { break }
      let x = random.unit()
      let y = random.unit()
      let density = max(0.15, 0.65 + noise.fbm(x * 3, y * 3) * 0.5)
      if random.unit() > density || hypot((x - 0.5) * 0.8, y - 0.5) > 0.48 { continue }
      let gx = Int(x / minDistance)
      let gy = Int(y / minDistance)
      var tooClose = false
      for dx in -1...1 {
        for dy in -1...1 {
          for existing in buckets[(gx + dx) * 101 + gy + dy] ?? [] {
            if hypot(existing.0 - x, existing.1 - y) < minDistance { tooClose = true }
          }
        }
      }
      if tooClose { continue }
      buckets[gx * 101 + gy, default: []].append((x, y))
      accepted += 1
      let radius = 0.0015 + pow(random.unit(), 3) * 0.007
      dot(
        x, y, radius, ink(accepted % 3, opacity: 0.3 + random.unit() * 0.65),
        elongation: 0.7 + random.unit() * 0.6)
    }
  }
}
