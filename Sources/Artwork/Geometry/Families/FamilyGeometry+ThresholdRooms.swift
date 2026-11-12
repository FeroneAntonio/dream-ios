import Foundation

extension FamilyGeometry {
  mutating func rooms() {
    let count = max(3, min(12, layer.primitiveCount))
    for index in 0..<count {
      let t = Double(index) / Double(count)
      let width = 0.88 * (1 - t * 0.82)
      let height = 0.91 * (1 - t * 0.75)
      let cx = 0.46 + t * 0.11
      let cy = 0.51 - t * 0.09
      let skew = 0.09 * (1 - t)
      let rough = 0.005 * layer.roughness
      let left = cx - width / 2
      let right = cx + width / 2
      let top = cy - height / 2
      let bottom = cy + height / 2
      polygon(
        [
          (right, top), (right + 0.027, bottom - 0.02), (right - 0.014, bottom),
          (right - 0.02, top + 0.02),
        ], ink(1, opacity: 0.15))
      var vertices: [(Double, Double)] = []
      for (a, b) in [
        ((left, bottom), (left - skew, top + skew)), ((left - skew, top + skew), (right, top)),
        ((right, top), (right, bottom)),
      ] {
        for step in 0...45 {
          let f = Double(step) / 45
          let jitter = noise.value(f * 4, Double(index)) * rough
          vertices.append((a.0 + (b.0 - a.0) * f + jitter, a.1 + (b.1 - a.1) * f + jitter))
        }
      }
      line(vertices, ink(0), width: 0.012 * (1 - t * 0.75))
      line([(left, bottom), (right, bottom)], ink(2, opacity: 0.7), width: 0.003)
    }
  }
}
