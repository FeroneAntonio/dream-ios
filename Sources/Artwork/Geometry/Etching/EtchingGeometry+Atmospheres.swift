import Foundation

extension EtchingGeometry {
  mutating func particles() {
    if study % 3 == 2 {
      attractor()
      return
    }
    let clusters = 2 + study
    var centers: [(Double, Double)] = []
    for _ in 0..<clusters {
      centers.append((0.18 + random.unit() * 0.64, 0.18 + random.unit() * 0.64))
    }
    for index in 0..<(650 + Int(density * 1200)) {
      let center = centers[index % clusters]
      let angle = random.unit() * Double.pi * 2
      let radius = pow(random.unit(), 1.8) * (0.12 + Double(index % 3) * 0.035)
      let x = center.0 + cos(angle) * radius
      let y = center.1 + sin(angle) * radius * 1.3
      let size = 0.0006 + pow(random.unit(), 3) * 0.0035
      drawing.dot(x, y, size, ink(index % 17 == 0 ? 2 : 0, 0.18 + random.unit() * 0.65))
    }
    if study % 2 == 0 {
      for center in centers.prefix(3) {
        volume(center: center, radius: 0.075, rings: 13, opening: 0.45)
      }
    }
  }

  mutating func void() {
    let center = (study % 2 == 0 ? -0.1 : 1.1, 0.35 + random.unit() * 0.4)
    for ring in 0..<36 {
      let radius = 0.25 + Double(ring) * 0.005
      var points: [(Double, Double)] = []
      for step in 0...140 {
        let angle = phase + Double(step) / 140 * Double.pi * 2
        points.append(
          (
            center.0 + cos(angle) * radius,
            center.1 + sin(angle) * radius * 1.2
          ))
      }
      drawing.line(points, ink(0, 0.15 + Double(ring) * 0.008), width: 0.0008)
    }
    guard layer.hasFocus else { return }
    let focus = (0.38 + random.unit() * 0.35, 0.22 + random.unit() * 0.4)
    drawing.glow(focus.0, focus.1, 0.08, ink(2, 0.32))
    drawing.dot(focus.0, focus.1, 0.0035, ink(0, 0.9))
  }

  mutating func haze() {
    if study >= 2 {
      attractor()
      return
    }
    let center = (0.32 + random.unit() * 0.36, 0.3 + random.unit() * 0.4)
    for index in 0..<4 {
      let x = center.0 + random.signed() * 0.12
      let y = center.1 + random.signed() * 0.15
      drawing.glow(
        x, y, 0.12 + random.unit() * 0.17, ink(index, 0.12), elongation: 0.6 + random.unit())
    }
    // A remembered blur still has an authored gesture, rather than only a soft gradient.
    ribbon(
      from: (0.15 + random.unit() * 0.2, 0.68 + random.unit() * 0.15),
      to: (0.58 + random.unit() * 0.24, 0.15 + random.unit() * 0.2),
      bend: random.signed() * 0.6, width: 0.16 + random.unit() * 0.17, strands: 65, color: 1)
    if study % 2 == 1 { volume(center: center, radius: 0.17, rings: 22, color: 0, opening: 0.8) }
  }
}
