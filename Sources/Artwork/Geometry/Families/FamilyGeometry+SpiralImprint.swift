import Foundation

extension FamilyGeometry {
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
}
