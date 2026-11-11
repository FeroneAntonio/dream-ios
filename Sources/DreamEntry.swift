import Foundation

struct DreamEntry: Codable, Identifiable, Hashable {
    var id = UUID()
    var date = Date.now
    var text: String
    var feeling: DreamFeeling
    var intensity: Double
    var reflection: String
    var question: String
    var usedAI: Bool
    var night: NightContext?
    var motif: DreamMotif = .orbit
    var title: String?
    var audioFilename: String?

    var displayTitle: String {
        if let title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return title }
        return String(text.split(whereSeparator: \.isNewline).first.map(String.init)?.prefix(70) ?? "A dream told aloud")
    }

    var seed: Double {
        Double((text.isEmpty ? id.uuidString : text).utf8.reduce(UInt64(5381)) { ($0 &* 33) &+ UInt64($1) } % 100_000)
    }
}
