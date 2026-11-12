import Foundation

struct RenderPoint: Codable, Hashable, Sendable {
  var x: Double
  var y: Double
  init(_ x: Double, _ y: Double) {
    self.x = (x * 1_000_000).rounded() / 1_000_000
    self.y = (y * 1_000_000).rounded() / 1_000_000
  }
}
