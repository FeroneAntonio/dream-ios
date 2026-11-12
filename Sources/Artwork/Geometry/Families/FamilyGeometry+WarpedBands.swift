import Foundation

extension FamilyGeometry {
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
}
