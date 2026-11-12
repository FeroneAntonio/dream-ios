import Foundation

extension EtchingGeometry {
  mutating func branching() {
    if study == 2 {
      drawing.branches()
      return
    }
    let count = min(5, max(2, layer.primitiveCount))
    let join = (0.35 + random.unit() * 0.3, 0.48 + random.unit() * 0.25)
    let spread = 1.5 + random.unit() * 1.3
    let direction = study % 3 == 0 ? -2.2 : -Double.pi / 2
    let radius = 0.34 + random.unit() * 0.14
    let stem = (0.32 + random.unit() * 0.38, 0.94)
    ribbon(from: stem, to: join, bend: random.signed() * 0.26, width: 0.025, strands: 19)
    for index in 0..<count {
      let fraction = Double(index) / Double(count - 1)
      let angle = direction + (fraction - 0.5) * spread
      let end = (
        min(0.94, max(0.06, join.0 + cos(angle) * radius)),
        min(0.90, max(0.06, join.1 + sin(angle) * radius))
      )
      ribbon(
        from: join, to: end, bend: random.signed() * 0.32,
        width: 0.10 + random.unit() * 0.12, strands: 35 + Int(density * 20))
    }
  }

  mutating func constellation() {
    let count = max(2, min(8, layer.primitiveCount))
    var centers: [(Double, Double)] = []
    for index in 0..<count {
      let fraction = Double(index) / Double(count - 1)
      centers.append(
        (
          0.20 + fraction * 0.60 + random.signed() * 0.055,
          0.5 + sin(fraction * Double.pi + phase) * 0.24
        ))
    }
    for index in 0..<count - 1 {
      ribbon(
        from: centers[index], to: centers[index + 1], bend: random.signed() * 0.35,
        width: 0.04 + random.unit() * 0.08, strands: 23)
    }
    for (index, center) in centers.enumerated() {
      volume(
        center: center, radius: 0.08 + random.unit() * 0.12, aspect: 0.6 + random.unit(),
        rings: 30 + Int(density * 28), color: index % 5 == 3 ? 2 : 0,
        opening: study == 4 ? 0.35 : 0)
    }
  }

  mutating func echoes() {
    let center = (0.3 + random.unit() * 0.38, 0.27 + random.unit() * 0.35)
    if study == 1 || study == 5 {
      // Successive displaced sections make a folded stack rather than one rosette.
      let count = 38 + Int(density * 30)
      for index in 0..<count {
        let t = Double(index) / Double(count - 1)
        var points: [(Double, Double)] = []
        for step in 0...140 {
          let angle = Double(step) / 140 * Double.pi * 2
          let width = 0.10 + sin(t * Double.pi) * 0.12
          let wobble = 1 + 0.07 * sin(angle * 3 + t * 4 + phase)
          points.append(
            (
              center.0 + (t - 0.5) * 0.4 + cos(angle) * width * wobble,
              0.16 + t * 0.68 + sin(angle) * 0.07 * wobble
            ))
        }
        drawing.line(points, ink(0, 0.6), width: index % 12 == 0 ? 0.0028 : 0.0009, closed: true)
      }
    } else if study == 3 {
      for index in 0..<3 {
        volume(
          center: (0.3 + Double(index) * 0.20, 0.34 + Double(index) * 0.13),
          radius: 0.19 + Double(index) * 0.025, aspect: 1.2, rings: 30, opening: 0.5)
      }
    } else {
      volume(
        center: center, radius: 0.38 + random.unit() * 0.18,
        aspect: 0.62 + random.unit() * 0.5, rings: 60 + Int(density * 28),
        opening: study == 4 ? 0.65 : 0)
    }
  }

  mutating func spirals() {
    if study >= 3 {
      knot()
      return
    }
    let center = (0.34 + random.unit() * 0.3, 0.32 + random.unit() * 0.3)
    let turns = 1.5 + random.unit() * 3.0
    let strands = 45 + Int(density * 36)
    let aspect = 0.65 + random.unit() * 0.55
    for strand in 0..<strands {
      let across = Double(strand) / Double(strands - 1) - 0.5
      var points: [(Double, Double)] = []
      for step in 0...420 {
        let t = Double(step) / 420
        let angle = phase + t * Double.pi * 2 * turns
        let radius = 0.035 + t * 0.39 + across * (0.035 + sin(t * Double.pi) * 0.11)
        let warp = 1 + 0.12 * sin(angle * 2 + phase) + noise.value(t * 5, across) * 0.035
        points.append(
          (
            center.0 + cos(angle) * radius * warp,
            center.1 + sin(angle) * radius * warp * aspect
          ))
      }
      drawing.line(
        points, ink(0, 0.28 + abs(across) * 0.9), width: strand % 17 == 0 ? 0.0025 : 0.00075)
    }
  }
}
