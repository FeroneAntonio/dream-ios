import Foundation

extension FamilyGeometry {
  mutating func branches() {
    let count = min(5, max(2, layer.primitiveCount))
    let root = (0.49, 0.94)
    let junction = (0.49, 0.69)
    line([root, junction], ink(3), width: 0.028)
    for index in 0..<count {
      let f = Double(index) / Double(count - 1)
      let end = (0.08 + f * 0.84, 0.09 + abs(f - 0.5) * 0.16)
      branch(from: junction, to: end, width: 0.018, depth: 3, color: index)
    }
  }
  mutating func branch(
    from a: (Double, Double), to b: (Double, Double), width: Double, depth: Int, color: Int
  ) {
    var vertices: [(Double, Double)] = []
    let bend = random.signed() * 0.055
    for step in 0...50 {
      let t = Double(step) / 50
      let dx =
        sin(t * Double.pi) * bend + noise.value(t * 4, Double(depth)) * 0.003 * layer.roughness
      vertices.append((a.0 + (b.0 - a.0) * t + dx, a.1 + (b.1 - a.1) * t))
    }
    if width > 0.004 {
      var left: [(Double, Double)] = []
      var right: [(Double, Double)] = []
      for index in vertices.indices {
        let previous = vertices[max(0, index - 1)]
        let next = vertices[min(vertices.count - 1, index + 1)]
        let dx = next.0 - previous.0
        let dy = next.1 - previous.1
        let length = max(0.0001, hypot(dx, dy))
        let t = Double(index) / Double(vertices.count - 1)
        let radius =
          width * 0.5 * (1 - t * 0.5)
          * (1 + noise.value(t * 6, Double(color)) * layer.roughness * 0.3)
        left.append(
          (vertices[index].0 - dy / length * radius, vertices[index].1 + dx / length * radius))
        right.append(
          (vertices[index].0 + dy / length * radius, vertices[index].1 - dx / length * radius))
      }
      polygon(left + right.reversed(), ink(color, opacity: 0.95))
    } else {
      line(vertices, ink(color, opacity: 0.95), width: width)
    }
    guard depth > 0 else { return }
    for side in [-1.0, 1.0] {
      let t = 0.48 + random.unit() * 0.24
      let start = (a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t)
      let finish = (
        min(0.95, max(0.05, start.0 + side * (0.05 + Double(depth) * 0.025))),
        min(0.9, max(0.04, b.1 + 0.04 + random.unit() * 0.06))
      )
      branch(from: start, to: finish, width: width * 0.46, depth: depth - 1, color: color)
    }
  }
}
