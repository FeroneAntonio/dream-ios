import Foundation

struct FinishRecipe: Codable, Hashable, Sendable {
  var grain = 0.35
  var edgeRoughness = 0.4
  var inkBleed = 0.15
  var isValid: Bool {
    [grain, edgeRoughness, inkBleed].allSatisfy { $0.isFinite && (0...1).contains($0) }
  }
}
