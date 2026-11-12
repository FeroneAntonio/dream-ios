import Foundation

struct SeededNoise: Sendable {
  var seed: UInt64
  private func lattice(_ x: Int, _ y: Int) -> Double {
    var generator = SeededRandom(
      seed: seed ^ (UInt64(bitPattern: Int64(x)) &* 0x9E37_79B9_7F4A_7C15)
        ^ (UInt64(bitPattern: Int64(y)) &* 0xD6E8_FEB8_6659_FD93))
    return generator.signed()
  }
  func value(_ x: Double, _ y: Double) -> Double {
    let ix = Int(floor(x))
    let iy = Int(floor(y))
    let fx = x - floor(x)
    let fy = y - floor(y)
    let u = fx * fx * fx * (fx * (fx * 6 - 15) + 10)
    let v = fy * fy * fy * (fy * (fy * 6 - 15) + 10)
    let a = lattice(ix, iy)
    let b = lattice(ix + 1, iy)
    let c = lattice(ix, iy + 1)
    let d = lattice(ix + 1, iy + 1)
    return (a + (b - a) * u) * (1 - v) + (c + (d - c) * u) * v
  }
  func fbm(_ x: Double, _ y: Double) -> Double {
    (value(x, y) + 0.5 * value(x * 2, y * 2) + 0.25 * value(x * 4, y * 4)) / 1.75
  }
}
