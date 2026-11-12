import Foundation

enum VisualPalette: String, Codable, CaseIterable, Identifiable, Sendable {
  case inkPaper, acidDream, chromaticHaze, nightPrint, mutedMemory
  var id: String { rawValue }
  var label: String {
    switch self {
    case .inkPaper: "Ink / Paper"
    case .acidDream: "Acid Dream"
    case .chromaticHaze: "Chromatic Haze"
    case .nightPrint: "Night Print"
    case .mutedMemory: "Muted Memory"
    }
  }
}
