import Foundation

extension FamilyGeometry {
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
}
