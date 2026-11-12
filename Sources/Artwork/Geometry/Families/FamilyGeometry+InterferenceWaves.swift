import Foundation

extension FamilyGeometry {
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
}
