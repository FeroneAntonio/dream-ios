import CryptoKit
import Foundation

struct DreamVisualRecipe: Codable, Hashable, Sendable {
  var grammarVersion = 1
  var seed: UInt64
  var inputFingerprint: String
  var layout: VisualLayout
  var layers: [VisualLayer]
  var palette: PaletteRecipe
  var finish = FinishRecipe()
  var motion = MotionRecipe()
  var decisions: [VisualDecision]
  var userAdjustments = UserVisualAdjustments()
  // Missing in the first installed recipe format: nil must retain renderer 1.
  var rendererVersion: Int?

  var isValid: Bool {
    grammarVersion == 1 && (rendererVersion == nil || rendererVersion == 1 || rendererVersion == 2)
      && inputFingerprint.count == 64
      && inputFingerprint.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
      && (1...3).contains(layers.count) && layers.filter { $0.role == .primary }.count == 1
      && layers.allSatisfy(\.isValid) && palette.isValid && finish.isValid && motion.isValid
      && userAdjustments.isValid && decisions.count <= 24 && decisions.allSatisfy(\.isValid)
  }
  var why: String {
    let active = decisions.filter { !$0.overridden }
    let narrative = active.filter {
      $0.familyAffected != nil && [.narrative, .modelSuggestion].contains($0.source)
    }
    let reasons = narrative.isEmpty ? active.filter { $0.ruleID == "quiet-fallback" } : narrative
    var sentences = Array(reasons.prefix(2).map(\.detail))
    if let user = active.last(where: { $0.source == .userChoice }) {
      sentences.append(user.detail)
    } else {
      sentences.append("These are artistic choices you can change.")
    }
    return sentences.joined(separator: " ")
  }
  var accessibleDescription: String {
    let main = layers.first { $0.role == .primary }
    let primary =
      main?.family == .negativeVoid && main?.hasFocus == false
      ? "Open space with peripheral ink contours" : main?.family.label ?? "Abstract print"
    let secondary = layers.filter { $0.role != .primary }.map { $0.family.label.lowercased() }
      .joined(separator: " and ")
    return
      "Dream portrait. \(primary)\(secondary.isEmpty ? "" : ", with \(secondary)"). \(palette.name.label) colors.\(rendererVersion == 2 ? " Pressure-varied ink and graphite hatching." : "")"
  }
  var identity: String { Self.digest((try? Self.encoder.encode(self)) ?? Data()) }
  static var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return encoder
  }
  static func fingerprint(_ text: String) -> String {
    digest(
      Data(text.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased().utf8))
  }
  static func digest(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
  }
}
