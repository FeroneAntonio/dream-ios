import Foundation

extension FamilyGeometry {
  mutating func rays() {
    let focus = (0.27, 0.79)
    let count = 20 + Int(layer.density * 24)
    for index in 0..<count {
      let a = -Double.pi * 0.96 + Double(index) / Double(count) * Double.pi * 1.1
      let b = a + 0.008 + random.unit() * 0.038
      let r = 0.5 + random.unit() * 0.8
      polygon(
        [
          focus, (focus.0 + cos(a) * r, focus.1 + sin(a) * r),
          (focus.0 + cos(b) * r, focus.1 + sin(b) * r),
        ], ink(index, opacity: 0.9))
      if index % 3 == 0 {
        line(
          [focus, (focus.0 + cos(b) * r, focus.1 + sin(b) * r)], ink(0, opacity: 0.5), width: 0.001)
      }
    }
  }
}
