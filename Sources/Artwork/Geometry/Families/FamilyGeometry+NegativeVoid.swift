import Foundation

extension FamilyGeometry {
  mutating func void() {
    // No figurative silhouette: a large unmarked region, rough peripheral arcs,
    // and one small off-center light. Empty space remains the dominant shape.
    let focus = (0.76, 0.25)
    for index in 0..<25 {
      let t = Double(index) / 25
      var vertices: [(Double, Double)] = []
      for step in 0...100 {
        let a = Double(step) / 100 * 1.65 + 0.2
        let radius = 0.67 + t * 0.21 + noise.value(a * 3, t * 5) * 0.007
        vertices.append((0.63 - cos(a) * radius, 0.24 + sin(a) * radius))
      }
      line(vertices, ink(index % 2, opacity: 0.35 * (1 - t)), width: 0.002)
    }
    guard layer.hasFocus else { return }
    glow(focus.0, focus.1, 0.17, ink(1, opacity: 0.22))
    glow(focus.0, focus.1, 0.065, ink(2, opacity: 0.7))
    dot(focus.0, focus.1, 0.006, ink(0))
  }
}
