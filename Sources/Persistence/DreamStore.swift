import Foundation
import Observation

/// Commits portrait and journal files together; failed writes retain the last saved diary.
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
    do { entries = try JSONDecoder().decode([DreamEntry].self, from: Data(contentsOf: file)) } catch
    {
      canWrite = false
      self.error = "The journal could not be opened. Your original data has been preserved."
    }
  }

  @discardableResult
  func save(_ entry: DreamEntry, portraitData: Data? = nil) -> Bool {
    guard canWrite else { return false }
    var saved = entry
    let previous = entries.first { $0.id == entry.id }
    var createdSnapshot: URL?
    do {
      if let data = portraitData, let recipe = entry.visualRecipe {
        guard recipe.isValid, data.count <= 20_000_000,
          data.prefix(8) == Data([137, 80, 78, 71, 13, 10, 26, 10])
        else { throw CocoaError(.coderInvalidValue) }
        let filename = "\(entry.id.uuidString)-\(recipe.identity).png"
        let folder = directory.appending(path: "portraits", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appending(path: filename)
        if !FileManager.default.fileExists(atPath: url.path()) {
          try data.write(to: url, options: [.atomic, .completeFileProtection])
          createdSnapshot = url
        }
        saved.portraitSnapshot = filename
      } else if previous?.visualRecipe != saved.visualRecipe
        && previous?.portraitSnapshot == saved.portraitSnapshot
      {
        // A newly composed recipe must never display its predecessor's PNG.
        saved.portraitSnapshot = nil
      } else if previous?.visualRecipe == saved.visualRecipe && saved.portraitSnapshot == nil {
        saved.portraitSnapshot = previous?.portraitSnapshot
      }
      var updated = entries
      if let index = updated.firstIndex(where: { $0.id == saved.id }) {
        updated[index] = saved
      } else {
        updated.insert(saved, at: 0)
      }
      try write(updated)
      entries = updated
      error = nil
      if let previous, previous.portraitSnapshot != saved.portraitSnapshot {
        removeSnapshot(previous)
      }
      return true
    } catch {
      if let createdSnapshot { try? FileManager.default.removeItem(at: createdSnapshot) }
      self.error = "Your dream could not be saved. It is still here; please try again."
      return false
    }
  }

  func snapshotURL(for entry: DreamEntry) -> URL? {
    let saved = entries.first { $0.id == entry.id && $0.visualRecipe == entry.visualRecipe }
    guard let name = entry.portraitSnapshot ?? saved?.portraitSnapshot,
      name == URL(fileURLWithPath: name).lastPathComponent,
      name.hasPrefix(entry.id.uuidString + "-"), name.hasSuffix(".png")
    else { return nil }
    return directory.appending(path: "portraits").appending(path: name)
  }
  private func removeSnapshot(_ entry: DreamEntry) {
    guard let url = snapshotURL(for: entry),
      !entries.contains(where: { $0.portraitSnapshot == entry.portraitSnapshot })
    else { return }
    try? FileManager.default.removeItem(at: url)
  }

  func delete(_ entry: DreamEntry) {
    guard canWrite, let saved = entries.first(where: { $0.id == entry.id }) else { return }
    let updated = entries.filter { $0.id != entry.id }
    do {
      try write(updated)
      entries = updated
      error = nil
      removeSnapshot(saved)
      if let filename = saved.audioFilename,
        filename == URL(fileURLWithPath: filename).lastPathComponent,
        filename.hasPrefix(saved.id.uuidString + "."),
        !entries.contains(where: { $0.audioFilename == filename })
      {
        let audio = directory.appending(path: "audio").appending(path: filename)
        try? FileManager.default.removeItem(at: audio)
      }
    } catch { self.error = "This dream could not be deleted." }
  }

  private func write(_ entries: [DreamEntry]) throws {
    let data = try JSONEncoder().encode(entries)
    try data.write(to: file, options: [.atomic, .completeFileProtection])
  }
}
