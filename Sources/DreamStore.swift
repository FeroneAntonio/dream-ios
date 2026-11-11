import Foundation
import Observation

@MainActor @Observable
final class DreamStore {
    private(set) var entries: [DreamEntry] = []
    var error: String?
    private let file: URL
    private let directory: URL
    private var canWrite = true

    init(directory: URL = .documentsDirectory) {
        self.directory = directory
        file = directory.appending(path: "dreams.json")
        guard FileManager.default.fileExists(atPath: file.path()) else { return }
        do { entries = try JSONDecoder().decode([DreamEntry].self, from: Data(contentsOf: file)) }
        catch { canWrite = false; self.error = "The journal could not be opened. Your original data has been preserved." }
    }

    @discardableResult
    func save(_ entry: DreamEntry) -> Bool {
        guard canWrite else { return false }
        var updated = entries
        if let index = updated.firstIndex(where: { $0.id == entry.id }) { updated[index] = entry }
        else { updated.insert(entry, at: 0) }
        do {
            try write(updated)
            entries = updated
            error = nil
            return true
        } catch { self.error = "Your dream could not be saved. It is still here; please try again."; return false }
    }

    func delete(_ entry: DreamEntry) {
        guard canWrite else { return }
        let updated = entries.filter { $0.id != entry.id }
        do {
            try write(updated)
            entries = updated
            error = nil
            if let filename = entry.audioFilename {
                let audio = directory.appending(path: "audio").appending(path: filename)
                try? FileManager.default.removeItem(at: audio)
            }
        }
        catch { self.error = "This dream could not be deleted." }
    }

    private func write(_ entries: [DreamEntry]) throws {
        let data = try JSONEncoder().encode(entries)
        try data.write(to: file, options: [.atomic, .completeFileProtection])
    }
}
