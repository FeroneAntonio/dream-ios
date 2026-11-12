import Foundation

extension HandDrawnRenderer {
  static func hatching(polygon: [RenderPoint], seed: UInt64, color: VisualRGBA, spacing: Double)
    -> [RenderMark]
  {
    guard polygon.count >= 3 else { return [] }
    var random = SeededRandom(seed: seed)
    let angle = 0.55 + random.unit() * 0.5
    let c = cos(angle)
    let s = sin(angle)
    let points = polygon.map { RenderPoint($0.x * c + $0.y * s, -$0.x * s + $0.y * c) }
    let minimum = points.map(\.y).min() ?? 0
    let maximum = points.map(\.y).max() ?? 0
    guard maximum > minimum else { return [] }
    let count = min(240, Int((maximum - minimum) / spacing) + 1)
    var result: [RenderMark] = []
    for row in 0..<count {
      let v = minimum + Double(row) * spacing
      var intersections: [Double] = []
      for index in points.indices {
        let a = points[index]
        let b = points[(index + 1) % points.count]
        if (a.y > v) != (b.y > v) {
          intersections.append(a.x + (b.x - a.x) * (v - a.y) / (b.y - a.y))
        }
      }
      intersections.sort()
      for index in stride(from: 0, to: max(0, intersections.count - 1), by: 2) {
        let a = intersections[index]
        let b = intersections[index + 1]
        guard b - a > 0.002 else { continue }
        let overshoot = random.signed() * 0.0007
        let p = RenderPoint(a * c - v * s - overshoot, a * s + v * c)
        let q = RenderPoint(b * c - v * s + overshoot, b * s + v * c)
        result.append(
          RenderMark(
            kind: .line, points: [p, q], color: color.opacity(0.55 + random.unit() * 0.45),
            width: 0.00065 + random.unit() * 0.00055))
      }
    }
    return result
  }
}
