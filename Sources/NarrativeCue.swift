import Foundation

struct NarrativeCue: Codable, Hashable, Sendable {
  var kind: NarrativeCueKind
  var excerpt: String
  var count: Int = 1
  var source: VisualEvidenceSource = .narrative
}
