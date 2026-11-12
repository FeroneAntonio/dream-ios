import Foundation

extension EtchingGeometry {
  mutating func currents() {
    let count = 80 + Int(density * 70)
    let center = 0.3 + random.unit() * 0.4
    let amplitude = 0.05 + random.unit() * 0.18
    let frequency = 1.2 + random.unit() * 2.7
    let crossing = [.crossing, .drifting, .still].contains(layer.direction)
    for index in 0..<count {
      let across = Double(index) / Double(count - 1) - 0.5
      var points: [(Double, Double)] = []
      for step in 0...180 {
        let t = Double(step) / 180
        let travel = layer.direction == .rising ? 1.04 - t * 1.08 : -0.04 + t * 1.08
        let envelope = 0.35 + 0.65 * pow(max(0, sin(t * Double.pi)), 0.7)
        let meander =
          sin(t * frequency * Double.pi + phase) * amplitude
          + noise.value(t * 3, across * 1.7) * 0.10 * layer.turbulence
        var width = 0.36 + 0.23 * cos(t * Double.pi * 2 + phase)
        var x = center + meander + across * width * envelope
        if layer.converges {
          let remaining = max(0, (0.77 - travel) / 0.81)
          width = 0.85 * pow(remaining, 0.8)
          x = 0.57 + across * width + meander * remaining
          if travel >= 0.77 {
            points.append((0.57, 0.77))
            break
          }
        }
        points.append(crossing ? (travel, x) : (x, travel))
      }
      drawing.line(
        points, ink(index % 31 == 0 ? 2 : 0, index % 15 == 0 ? 0.9 : 0.42),
        width: index % 15 == 0 ? 0.003 : 0.00085)
    }
  }

  mutating func wovenBands() {
    let count = 9 + study * 2
    let vertical = study % 2 == 0
    let amplitude = 0.025 + random.unit() * 0.09
    let frequency = 1.3 + random.unit() * 2.8
    for index in 0..<count {
      let center = 0.10 + Double(index) / Double(count - 1) * 0.80
      let band = 0.012 + random.unit() * 0.028
      for strand in 0..<14 {
        let offset = (Double(strand) / 13 - 0.5) * band
        var points: [(Double, Double)] = []
        for step in 0...160 {
          let t = Double(step) / 160
          let warped =
            center + offset + sin(t * Double.pi * frequency + phase + center * 2) * amplitude
            + noise.value(t * 3, center * 3) * 0.03
          points.append(vertical ? (warped, t * 0.9 + 0.05) : (t * 0.9 + 0.05, warped))
        }
        drawing.line(
          points, ink(index % 5 == 3 ? 2 : 0, strand % 13 == 0 ? 0.9 : 0.45),
          width: strand % 13 == 0 ? 0.0025 : 0.0008)
      }
    }
  }

  mutating func interference() {
    if study % 2 == 1 {
      knot()
      return
    }
    let centers = [
      (0.26 + random.unit() * 0.15, 0.3 + random.unit() * 0.3),
      (0.60 + random.unit() * 0.15, 0.38 + random.unit() * 0.3),
    ]
    let aspect = 0.55 + random.unit() * 0.6
    for (field, center) in centers.enumerated() {
      for ring in 0..<56 {
        let radius = 0.025 + Double(ring) * 0.0065
        var points: [(Double, Double)] = []
        for step in 0...150 {
          let angle = Double(step) / 150 * Double.pi * 2
          let wave = 1 + 0.08 * sin(angle * 3 + phase + Double(field))
          points.append(
            (
              center.0 + cos(angle) * radius * wave,
              center.1 + sin(angle) * radius * wave * aspect
            ))
        }
        drawing.line(
          points, ink(field, 0.62), width: ring % 11 == 0 ? 0.002 : 0.00085, closed: true)
      }
    }
  }
}
