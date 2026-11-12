import Foundation

struct NarrativeVisualFeatures: Codable, Hashable, Sendable {
  var inputFingerprint: String
  var cues: [NarrativeCue]
  var usedLanguageModel = false
  var analyzedBeginningOnly = false
  func first(_ kind: NarrativeCueKind) -> NarrativeCue? { cues.first { $0.kind == kind } }
  func has(_ kind: NarrativeCueKind) -> Bool { first(kind) != nil }
}
