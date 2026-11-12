import Foundation

struct LegacyPortrait: Codable, Hashable {
  var seed: Double
  var feeling: DreamFeeling
  var intensity: Double
  var motif: DreamMotif
  var isValid: Bool {
    seed.isFinite && (0..<100_000).contains(seed) && intensity.isFinite
      && (0...1).contains(intensity)
  }
}
