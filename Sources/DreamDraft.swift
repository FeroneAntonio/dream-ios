import Foundation

struct DreamDraft: Codable, Equatable {
    var text = ""
    var feeling = DreamFeeling.wonder
    var intensity = 0.5
    var isEmpty: Bool { text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}
