import Foundation

extension FamilyGeometry {
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
}
