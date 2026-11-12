import SwiftUI

enum SleepStage: String, Codable, CaseIterable, Identifiable {
  case awake, light, deep, rem, unknown
  var id: String { rawValue }
  var label: String {
    switch self {
    case .awake: "Awake"
    case .light: "Light"
    case .deep: "Deep"
    case .rem: "REM"
    case .unknown: "Unclassified"
    }
  }
  var color: Color {
    switch self {
    case .awake: .gray
    case .light: .teal
    case .deep: .indigo
    case .rem: .orange
    case .unknown: .gray.opacity(0.35)
    }
  }
  var isSleep: Bool { self == .light || self == .deep || self == .rem }
  static let modelOrder: [Self] = [.awake, .light, .deep, .rem]
}
