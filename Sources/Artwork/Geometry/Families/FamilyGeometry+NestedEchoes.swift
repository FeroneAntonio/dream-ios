import Foundation

extension FamilyGeometry {
  mutating func echoes() {
    let count = 22 + Int(layer.density * 35)
    for index in 0..<count {
      let t = Double(index) / Double(count)
      let radius = 0.035 + t * 0.56
      var vertices: [(Double, Double)] = []
      for step in 0...200 {
        let angle = Double(step) / 200 * 2 * Double.pi
        // Superelliptic, offset contours: rectilinear landings with soft corners.
        let c = cos(angle)
        let s = sin(angle)
        let sx = (c >= 0 ? 1.0 : -1.0) * pow(abs(c), 0.52)
        let sy = (s >= 0 ? 1.0 : -1.0) * pow(abs(s), 0.52)
        let rough = noise.value(angle * 2, Double(index) * 0.12) * 0.008 * layer.roughness
        let cx = 0.49 + sin(t * 3.7) * 0.055
        let cy = 0.36 + t * 0.16
        vertices.append((cx + sx * (radius + rough), cy + sy * (radius * 0.93 + rough)))
      }
      line(
        vertices, ink(index % 9 == 0 ? 1 : 0, opacity: 0.8), width: index % 8 == 0 ? 0.006 : 0.0018,
        closed: true)
    }
  }
}
