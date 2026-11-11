import Foundation

@MainActor
final class DreamDraftStore {
    private let file: URL

    init(directory: URL = .documentsDirectory) {
        file = directory.appending(path: "dream-draft.json")
    }

    func load() throws -> DreamDraft? {
        guard FileManager.default.fileExists(atPath: file.path()) else { return nil }
        return try JSONDecoder().decode(DreamDraft.self, from: Data(contentsOf: file))
    }

    func save(_ draft: DreamDraft) throws {
        if draft.isEmpty { try clear(); return }
        let data = try JSONEncoder().encode(draft)
        try data.write(to: file, options: [.atomic, .completeFileProtection])
    }

    func clear() throws {
        if FileManager.default.fileExists(atPath: file.path()) {
            try FileManager.default.removeItem(at: file)
        }
    }
}
