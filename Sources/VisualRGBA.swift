import Foundation

struct VisualRGBA: Codable, Hashable, Sendable {
  var r: Double
  var g: Double
  var b: Double
  var a: Double = 1
  init(_ hex: UInt32, alpha: Double = 1) {
    r = Double((hex >> 16) & 255) / 255
    g = Double((hex >> 8) & 255) / 255
    b = Double(hex & 255) / 255
    a = alpha
  }
  var isValid: Bool { [r, g, b, a].allSatisfy { $0.isFinite && (0...1).contains($0) } }
  func opacity(_ value: Double) -> Self {
    var copy = self
    copy.a *= min(1, max(0, value))
    return copy
  }
  var luminance: Double { 0.2126 * r + 0.7152 * g + 0.0722 * b }
}
