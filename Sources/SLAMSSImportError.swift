import Foundation

enum SLAMSSImportError: LocalizedError {
    case invalidReport, synthetic, wrongNight, tooLarge
    var errorDescription: String? {
        switch self {
        case .invalidReport: "This is not a supported SLAMSS-IFS report. Check its model provenance, 30-second epochs and four finite scores per epoch."
        case .synthetic: "Synthetic or smoke-test predictions cannot be attached as a real night."
        case .wrongNight: "This report does not match the night before this dream."
        case .tooLarge: "This research report is too large. Export at most 1,200 epochs (10 hours)."
        }
    }
}
