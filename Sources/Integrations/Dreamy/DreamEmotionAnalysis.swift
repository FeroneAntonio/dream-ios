import Foundation

struct DreamEmotionAnalysis: Codable, Hashable, Sendable {
  static let revision = "302196dad5648c1a28d70de3055373ef11975f04"
  var modelRevision = Self.revision
  var scores: [Double]
  var truncated: Bool

  init(logits: [Double], truncated: Bool) throws {
    guard logits.count == 5, logits.allSatisfy(\.isFinite) else {
      throw CocoaError(.coderInvalidValue)
    }
    scores = logits.map { value in
      value >= 0 ? 1 / (1 + exp(-value)) : exp(value) / (1 + exp(value))
    }
    self.truncated = truncated
  }

  var isValid: Bool {
    modelRevision == Self.revision && scores.count == 5
      && scores.allSatisfy { $0.isFinite && (0...1).contains($0) }
  }
  var present: [DreamEmotion] {
    guard isValid else { return [] }
    return zip(DreamEmotion.allCases, scores).compactMap { $1 > 0.5 ? $0 : nil }
  }
  var summary: String { present.map(\.label).joined(separator: ", ") }
  // Legacy-only display compatibility. New portraits use VisualRuleEngine,
  // where independent hints never choose the primary family or palette.
  var suggestedMotif: DreamMotif? {
    if present.contains(.confusion) { return .fragment }
    if present.contains(.sadness) { return .flow }
    if present.contains(.happiness) { return .orbit }
    return nil
  }
  var visualExplanation: String {
    switch suggestedMotif {
    case .fragment: "Broken paths echo the suggested confusion in the story."
    case .flow: "Flowing lines echo the suggested sadness in the story."
    case .orbit: "Open orbits echo the suggested happiness in the story."
    case nil: "The shapes follow the story and your selected feeling."
    }
  }
}
