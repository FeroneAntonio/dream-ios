import Foundation

extension FamilyGeometry {
  mutating func graph() {
    let count = max(2, min(8, layer.primitiveCount))
    var nodes: [(Double, Double)] =
      count == 2
      ? [
        (0.26 + random.signed() * 0.055, 0.49 + random.signed() * 0.065),
        (0.72 + random.signed() * 0.055, 0.4 + random.signed() * 0.065),
      ] : (0..<count).map { _ in (0.15 + random.unit() * 0.7, 0.18 + random.unit() * 0.64) }
    // Bounded spring/repulsion relaxation. Two named participants retain two foci.
    if count > 2 {
      for _ in 0..<60 {
        let before = nodes
        for i in nodes.indices {
          var fx = 0.0
          var fy = 0.0
          for j in nodes.indices where i != j {
            let dx = before[i].0 - before[j].0
            let dy = before[i].1 - before[j].1
            let d2 = max(0.005, dx * dx + dy * dy)
            fx += dx * (0.0015 / d2 - 0.012)
            fy += dy * (0.0015 / d2 - 0.012)
          }
          nodes[i] = (
            min(0.84, max(0.16, before[i].0 + fx)), min(0.84, max(0.16, before[i].1 + fy))
          )
        }
      }
    }
    for index in 0..<count - 1 {
      let a = nodes[index]
      let b = nodes[index + 1]
      for strand in 0..<12 {
        var vertices: [(Double, Double)] = []
        for step in 0...70 {
          let t = Double(step) / 70
          let offset = sin(t * Double.pi) * (0.035 + Double(strand) * 0.009)
          vertices.append((a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t + offset))
        }
        line(vertices, ink(strand % 2, opacity: 0.65), width: strand % 5 == 0 ? 0.004 : 0.0013)
      }
    }
    for index in nodes.indices {
      let node = nodes[index]
      let radius = index == 0 ? 0.074 : 0.054
      dot(node.0, node.1, radius + 0.012, paper.opacity(layer.opacity))
      dot(node.0, node.1, radius, ink(index == 0 ? 3 : 1))
      for ring in 0..<5 {
        let r = radius + 0.02 + Double(ring) * 0.006
        let points = (0...100).map { step -> (Double, Double) in
          let a = Double(step) / 100 * Double.pi * 2
          return (node.0 + cos(a) * r, node.1 + sin(a) * r)
        }
        line(points, ink(index, opacity: 0.7), width: 0.0012, closed: true)
      }
    }
  }
}
