import Foundation

extension FamilyGeometry {
  mutating func particles() {
    let target = 650 + Int(layer.density * 650)
    let minDistance = 0.012
    var buckets: [Int: [(Double, Double)]] = [:]
    var accepted = 0
    for _ in 0..<8000 {
      guard accepted < target else { break }
      let x = random.unit()
      let y = random.unit()
      let density = max(0.15, 0.65 + noise.fbm(x * 3, y * 3) * 0.5)
      if random.unit() > density || hypot((x - 0.5) * 0.8, y - 0.5) > 0.48 { continue }
      let gx = Int(x / minDistance)
      let gy = Int(y / minDistance)
      var tooClose = false
      for dx in -1...1 {
        for dy in -1...1 {
          for existing in buckets[(gx + dx) * 101 + gy + dy] ?? [] {
            if hypot(existing.0 - x, existing.1 - y) < minDistance { tooClose = true }
          }
        }
      }
      if tooClose { continue }
      buckets[gx * 101 + gy, default: []].append((x, y))
      accepted += 1
      let radius = 0.0015 + pow(random.unit(), 3) * 0.007
      dot(
        x, y, radius, ink(accepted % 3, opacity: 0.3 + random.unit() * 0.65),
        elongation: 0.7 + random.unit() * 0.6)
    }
  }
}
