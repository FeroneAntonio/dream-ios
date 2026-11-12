import Foundation

extension EtchingGeometry {
  /// Projected toroidal paths produce interwoven folds with changing cross-sections.
  mutating func knot() {
    let winding = 2 + study % 3
    let crossings = winding + 1
    let strands = 80 + Int(density * 50)
    let tilt = random.signed() * 0.8
    let flattening = 0.55 + random.unit() * 0.35
    for strand in 0..<strands {
      let across = Double(strand) / Double(strands - 1) - 0.5
      var points: [(Double, Double)] = []
      for step in 0...360 {
        let t = Double(step) / 360 * Double.pi * 2
        let radius =
          0.27 + cos(t * Double(crossings) + phase) * 0.07
          + across * (0.12 + 0.04 * sin(t * 3 + phase))
        let x = cos(t * Double(winding)) * radius
        let y =
          sin(t * Double(winding)) * radius * flattening
          + sin(t * Double(crossings) + phase) * 0.14
        points.append((0.5 + x * cos(tilt) - y * sin(tilt), 0.5 + x * sin(tilt) + y * cos(tilt)))
      }
      drawing.line(
        points, ink(strand % 29 == 0 ? 2 : 0, 0.22 + abs(across) * 0.9),
        width: strand % 19 == 0 ? 0.0022 : 0.00065, closed: true)
    }
  }

  /// A bounded Clifford map deposits ink; no pre-rendered texture is sampled.
  mutating func attractor() {
    let coefficients: [(Double, Double, Double, Double)] = [
      (-1.4, 1.6, 1.0, 0.7), (-1.7, 1.8, -1.9, -0.4),
      (1.5, -1.8, 1.6, 0.9), (-1.3, -1.3, -1.8, -1.9),
    ]
    let values = coefficients[study % coefficients.count]
    var a = values.0 + random.signed() * 0.035
    var b = values.1 + random.signed() * 0.035
    var c = values.2 + random.signed() * 0.035
    var d = values.3 + random.signed() * 0.035
    if !Self.hasOpenAttractor(a: a, b: b, c: c, d: d) {
      // Some coefficient neighborhoods collapse to one point; use an open orbit.
      a = -1.4
      b = 1.6
      c = 1.0
      d = 0.7
    }
    let scale = 0.12 + random.unit() * 0.025
    let tilt = random.signed() * 0.7
    var x = 0.1
    var y = 0.1
    // Leave room for two supporting layers and maximum paper grain in one print.
    let primaryBudget =
      drawing.recipe.layers.count == 1 ? 10000 + Int(density * 3500) : 6500 + Int(density * 1500)
    let deposits = layer.role == .primary ? primaryBudget : 2000 + Int(density * 600)
    for index in 0..<deposits {
      let nextX = sin(a * y) + c * cos(a * x)
      let nextY = sin(b * x) + d * cos(b * y)
      x = nextX
      y = nextY
      if index < 80 { continue }
      let px = 0.5 + (x * cos(tilt) - y * sin(tilt)) * scale
      let py = 0.5 + (x * sin(tilt) + y * cos(tilt)) * scale
      drawing.dot(
        px, py, 0.0009 + random.unit() * 0.0010,
        ink(index % 13 == 0 ? 2 : 0, 0.48 + random.unit() * 0.45))
    }
  }
  static func hasOpenAttractor(a: Double, b: Double, c: Double, d: Double) -> Bool {
    var x = 0.1
    var y = 0.1
    var minimumX = Double.infinity
    var maximumX = -Double.infinity
    var minimumY = Double.infinity
    var maximumY = -Double.infinity
    for index in 0..<1600 {
      let nextX = sin(a * y) + c * cos(a * x)
      let nextY = sin(b * x) + d * cos(b * y)
      x = nextX
      y = nextY
      if index >= 800 {
        minimumX = min(minimumX, x)
        maximumX = max(maximumX, x)
        minimumY = min(minimumY, y)
        maximumY = max(maximumY, y)
      }
    }
    return (maximumX - minimumX) * (maximumY - minimumY) > 0.7
  }

}
