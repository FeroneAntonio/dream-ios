import Foundation

struct VisualDecision: Codable, Hashable, Sendable {
  var ruleID: String
  var source: VisualEvidenceSource
  var evidenceExcerpt: String?
  var detail: String
  var familyAffected: VisualFamily?
  var overridden = false
  var isValid: Bool {
    !ruleID.isEmpty && ruleID.count < 100 && detail.count <= 600
      && (evidenceExcerpt?.count ?? 0) <= 240
  }
}
