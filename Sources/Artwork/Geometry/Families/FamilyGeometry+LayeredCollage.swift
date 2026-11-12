import Foundation

extension FamilyGeometry {
  mutating func collage() {
    for index in 0..<4 {
      let x = Double(index) * 0.25 - 0.08
      var upper: [(Double, Double)] = []
      var lower: [(Double, Double)] = []
      for step in 0...70 {
        let y = Double(step) / 70 * 1.12 - 0.06
        let tear = noise.value(y * 12, Double(index)) * 0.008
        upper.append((x + y * 0.18 + tear, y))
        lower.append((x + 0.34 + y * 0.06 + tear, y))
      }
      polygon(upper + lower.reversed(), ink(index, opacity: 0.9))
      line(upper, paper.opacity(0.65), width: 0.002)
    }
  }
}
