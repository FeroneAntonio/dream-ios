import Foundation

enum DreamEmotion: String, Codable, CaseIterable, Identifiable {
  // This order is the pinned checkpoint's id2label order, not alphabetical.
  case anger = "AN"
  case apprehension = "AP"
  case sadness = "SD"
  case confusion = "CO"
  case happiness = "HA"
  var id: String { rawValue }
  var label: String {
    switch self {
    case .anger: "Anger"
    case .apprehension: "Apprehension"
    case .sadness: "Sadness"
    case .confusion: "Confusion"
    case .happiness: "Happiness"
    }
  }
}
