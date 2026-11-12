import Foundation

struct UserVisualAdjustments: Codable, Hashable, Sendable {
  var energy: Double?
  var palette: VisualPalette?
  var isValid: Bool { energy.map { $0.isFinite && (0...1).contains($0) } ?? true }
}
