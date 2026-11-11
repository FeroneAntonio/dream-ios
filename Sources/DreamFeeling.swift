import SwiftUI

enum DreamFeeling: String, Codable, CaseIterable, Identifiable {
    case quiet = "Quiete", wonder = "Meraviglia", confusion = "Confusione", fear = "Paura"
    var id: String { rawValue }
    var label: String {
        switch self { case .quiet: "Calm"; case .wonder: "Wonder"; case .confusion: "Unsettled"; case .fear: "Fear" }
    }
    var color: Color {
        switch self {
        case .quiet: .init(red: 0.28, green: 0.43, blue: 0.40)
        case .wonder: .init(red: 0.72, green: 0.48, blue: 0.18)
        case .confusion: .init(red: 0.34, green: 0.40, blue: 0.55)
        case .fear: .init(red: 0.67, green: 0.27, blue: 0.20)
        }
    }
    var turbulence: Double {
        switch self { case .quiet: 0.15; case .wonder: 0.4; case .confusion: 0.85; case .fear: 1 }
    }
    var artColors: [Color] {
        switch self {
        case .quiet: [.init(red: 0.30, green: 0.78, blue: 0.72), .init(red: 0.48, green: 0.59, blue: 0.90), .init(red: 0.75, green: 0.90, blue: 0.81)]
        case .wonder: [.init(red: 0.98, green: 0.68, blue: 0.36), .init(red: 0.84, green: 0.45, blue: 0.55), .init(red: 0.67, green: 0.85, blue: 0.81)]
        case .confusion: [.init(red: 0.42, green: 0.59, blue: 0.96), .init(red: 0.94, green: 0.49, blue: 0.36), .init(red: 0.78, green: 0.67, blue: 0.91)]
        case .fear: [.init(red: 1, green: 0.30, blue: 0.20), .init(red: 0.98, green: 0.63, blue: 0.24), .init(red: 0.72, green: 0.22, blue: 0.38)]
        }
    }
}
