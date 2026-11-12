import Foundation

extension EtchingGeometry {
  mutating func architecture() {
    let count = max(3, min(12, layer.primitiveCount))
    let vanishing = (0.23 + random.unit() * 0.5, 0.2 + random.unit() * 0.4)
    let opening = 0.70 + random.unit() * 0.2
    var previous: [(Double, Double)]?
    for index in 0..<count {
      let t = Double(index) / Double(count)
      let scale = pow(1 - t, 1.1) * opening + 0.055
      let cx = vanishing.0 + (0.5 - vanishing.0) * (1 - t) + sin(t * 4 + phase) * 0.07
      let cy = vanishing.1 + (0.53 - vanishing.1) * (1 - t)
      let skew = (study % 2 == 0 ? 1.0 : -1.0) * (0.08 + random.unit() * 0.05) * (1 - t)
      let points = [
        (cx - scale * 0.5, cy + scale * 0.5),
        (cx - scale * 0.5 + skew, cy - scale * 0.5),
        (cx + scale * 0.5, cy - scale * 0.38),
        (cx + scale * 0.5 - skew, cy + scale * 0.5),
      ]
      if let previous, index % 2 == study % 2 {
        let side = study % 3 == 0 ? 0 : 2
        drawing.polygon(
          [previous[side], previous[side + 1], points[side + 1], points[side]],
          ink(0, 0.42))
      }
      if study == 1 || study == 4 {
        var arch: [(Double, Double)] = [(cx - scale * 0.45, cy + scale * 0.5)]
        for step in 0...90 {
          let angle = Double.pi + Double(step) / 90 * Double.pi
          arch.append((cx + cos(angle) * scale * 0.45, cy + sin(angle) * scale * 0.65))
        }
        arch.append((cx + scale * 0.45, cy + scale * 0.5))
        drawing.line(arch, ink(0, 0.9), width: 0.0028 * (1 - t * 0.65))
      } else {
        drawing.line(points, ink(0, 0.94), width: 0.0035 * (1 - t * 0.7))
      }
      if study >= 3 {
        let depth = 0.012 + random.unit() * 0.03
        let echo = points.map { ($0.0 + depth, $0.1 - depth) }
        drawing.line(echo, ink(1, 0.4), width: 0.0008)
        for corner in [0, 3] {
          drawing.line([points[corner], echo[corner]], ink(0, 0.65), width: 0.001)
        }
      }
      previous = points
    }
  }

  mutating func rays() {
    let focus = (0.24 + random.unit() * 0.52, 0.3 + random.unit() * 0.4)
    let count = 9 + Int(density * 15)
    let sweep = Double.pi * (study % 2 == 0 ? 1.45 : 2.0)
    for index in 0..<count {
      let angle = phase + Double(index) / Double(count) * sweep
      let radius = 0.2 + random.unit() * 0.42
      let width = 0.018 + random.unit() * 0.07
      let tip = (focus.0 + cos(angle) * radius, focus.1 + sin(angle) * radius)
      let shoulder = (
        focus.0 + cos(angle + width) * radius * 0.8,
        focus.1 + sin(angle + width) * radius * 0.8
      )
      drawing.polygon(
        [focus, tip, shoulder], ink(index % 7 == 0 ? 2 : 0, 0.35 + random.unit() * 0.4))
      drawing.line([focus, tip], ink(0, 0.9), width: 0.0014)
    }
  }

  mutating func fragments() {
    // Retain actual Voronoi topology; make space for the silhouette of the cut mass.
    var fragmentLayer = layer
    fragmentLayer.scale *= 0.60 + random.unit() * 0.28
    fragmentLayer.anchor.x += random.signed() * 0.06
    fragmentLayer.anchor.y += random.signed() * 0.06
    var fragments = FamilyGeometry(recipe: drawing.recipe, layer: fragmentLayer)
    fragments.cells()
    for var mark in fragments.marks {
      let centerX = mark.points.reduce(0) { $0 + $1.x } / Double(max(1, mark.points.count))
      let centerY = mark.points.reduce(0) { $0 + $1.y } / Double(max(1, mark.points.count))
      let dx = (centerX - layer.anchor.x) / max(0.1, fragmentLayer.scale * 0.49)
      let dy = (centerY - layer.anchor.y) / max(0.1, fragmentLayer.scale * 0.49)
      guard dx * dx + dy * dy < 0.95 + noise.value(dx * 2, dy * 2) * 0.2 else { continue }
      let shiftX = noise.value(centerX * 15, centerY * 15) * 0.018
      let shiftY = noise.value(centerY * 15, centerX * 15) * 0.018
      mark.points = mark.points.map { RenderPoint($0.x + shiftX, $0.y + shiftY) }
      drawing.marks.append(mark)
    }
  }

  mutating func collage() {
    let count = 3 + study % 4
    for index in 0..<count {
      let angle = phase + Double(index) * 0.7
      let cx = 0.25 + random.unit() * 0.5
      let cy = 0.22 + random.unit() * 0.56
      let width = 0.09 + random.unit() * 0.14
      let length = 0.17 + random.unit() * 0.25
      var left: [(Double, Double)] = []
      var right: [(Double, Double)] = []
      for step in 0...70 {
        let t = Double(step) / 70
        let tear = noise.value(t * 14, Double(index)) * 0.009
        let x = (t - 0.5) * length * 2
        let y = sin(t * Double.pi) * 0.05
        left.append(
          (
            cx + x * cos(angle) - (y - width + tear) * sin(angle),
            cy + x * sin(angle) + (y - width + tear) * cos(angle)
          ))
        right.append(
          (
            cx + x * cos(angle) - (y + width + tear) * sin(angle),
            cy + x * sin(angle) + (y + width + tear) * cos(angle)
          ))
      }
      drawing.polygon(left + right.reversed(), ink(index % 4 == 2 ? 2 : 0, 0.40))
      drawing.line(left, ink(0, 0.95), width: 0.002)
    }
  }
}
