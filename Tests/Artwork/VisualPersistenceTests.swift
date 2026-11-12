import Foundation
import Testing

@testable import DREAM

@MainActor
struct VisualPersistenceTests {
  private func directory() throws -> URL {
    let url = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
  }
  private func entry() -> DreamEntry {
    let text = "I opened seven doors."
    return DreamEntry(
      text: text, feeling: .wonder, intensity: 0.5, reflection: "", question: "", usedAI: false,
      visualRecipe: VisualRuleEngine.compose(
        features: NarrativeVisualAnalyzer.local(text), seed: 202))
  }
  private func png(_ entry: DreamEntry) throws -> Data {
    let recipe = try #require(entry.visualRecipe)
    return try ProceduralRasterizer.png(
      plan: ProceduralRenderEngine.makePlan(recipe: recipe), pixels: 88)
  }

  @Test func genuinelyOldJSONMissingMotifAndAllNewFieldsCanBeEditedWithoutRedrawing() throws {
    let json = """
      {"id":"C5F468F1-458B-422D-82DF-A24FE91C0838","date":0,"text":"A quiet room.","feeling":"Quiete","intensity":0.3,"reflection":"My own words","question":"Why?","usedAI":false}
      """
    var old = try JSONDecoder().decode(DreamEntry.self, from: Data(json.utf8))
    #expect(old.visualRecipe == nil)
    #expect(old.motif == .orbit)
    let originalSeed = old.seed
    old.text = "I added a door to the story."
    #expect(old.legacyPortrait?.seed == originalSeed)
    let dir = try directory()
    defer { try? FileManager.default.removeItem(at: dir) }
    let store = DreamStore(directory: dir)
    try #require(store.save(old))
    let reopened = try #require(DreamStore(directory: dir).entries.first)
    #expect(reopened == old)
    #expect(reopened.reflection == "My own words")
    #expect(reopened.legacyPortrait?.seed == originalSeed)
  }

  @Test func textEditKeepsRecipeAndSnapshotUntilAnExplicitRecreation() throws {
    let dir = try directory()
    defer { try? FileManager.default.removeItem(at: dir) }
    let store = DreamStore(directory: dir)
    let original = entry()
    try #require(store.save(original, portraitData: png(original)))
    var edited = try #require(store.entries.first)
    let savedRecipe = edited.visualRecipe
    let snapshot = try #require(store.snapshotURL(for: edited))
    let data = try Data(contentsOf: snapshot)
    edited.text = "The path split into three."
    try #require(store.save(edited))
    #expect(edited.visualRecipe == savedRecipe)
    #expect(edited.portraitUsesEarlierText)
    #expect(try Data(contentsOf: snapshot) == data)
    var recreated = edited
    recreated.visualRecipe = VisualRuleEngine.compose(
      features: NarrativeVisualAnalyzer.local(edited.text), seed: 201)
    try #require(store.save(recreated, portraitData: png(recreated)))
    #expect(FileManager.default.fileExists(atPath: snapshot.path()) == false)
    #expect(store.entries.first?.portraitUsesEarlierText == false)
    #expect(store.entries.first?.visualRecipe?.layers[0].family == .branchingPaths)
  }

  @Test func snapshotsPersistAcrossReopeningAndStaleMetadataSaves() throws {
    let dir = try directory()
    defer { try? FileManager.default.removeItem(at: dir) }
    let store = DreamStore(directory: dir)
    var dream = entry()
    let data = try png(dream)
    try #require(store.save(dream, portraitData: data))
    dream.reflection = "A new note"  // Caller has no snapshot filename yet.
    try #require(store.save(dream))
    let reopened = DreamStore(directory: dir)
    let saved = try #require(reopened.entries.first)
    let snapshot = try #require(reopened.snapshotURL(for: saved))
    #expect(try Data(contentsOf: snapshot) == data)
    #expect(saved.reflection == "A new note")
  }

  @Test func failedJournalTransactionRollsBackOnlyTheNewSnapshot() throws {
    let dir = try directory()
    defer { try? FileManager.default.removeItem(at: dir) }
    let store = DreamStore(directory: dir)
    try FileManager.default.createDirectory(
      at: dir.appending(path: "dreams.json"), withIntermediateDirectories: true)
    let dream = entry()
    #expect(store.save(dream, portraitData: try png(dream)) == false)
    #expect(store.entries.isEmpty)
    let files = try FileManager.default.contentsOfDirectory(
      atPath: dir.appending(path: "portraits").path())
    #expect(files.isEmpty)
  }

  @Test func corruptedDiaryCannotBeOverwrittenBySnapshotSave() throws {
    let dir = try directory()
    defer { try? FileManager.default.removeItem(at: dir) }
    let file = dir.appending(path: "dreams.json")
    let damaged = Data("broken-json".utf8)
    try damaged.write(to: file)
    let store = DreamStore(directory: dir)
    let dream = entry()
    #expect(store.save(dream, portraitData: try png(dream)) == false)
    #expect(try Data(contentsOf: file) == damaged)
    #expect(
      FileManager.default.fileExists(atPath: dir.appending(path: "portraits").path()) == false)
  }

  @Test func deletingOneDreamRemovesItsSnapshotAndAudioOnly() throws {
    let dir = try directory()
    defer { try? FileManager.default.removeItem(at: dir) }
    let audio = dir.appending(path: "audio", directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: audio, withIntermediateDirectories: true)
    let store = DreamStore(directory: dir)
    var first = entry()
    var second = entry()
    first.audioFilename = first.id.uuidString + ".m4a"
    second.audioFilename = second.id.uuidString + ".m4a"
    let firstAudio = audio.appending(path: try #require(first.audioFilename))
    let secondAudio = audio.appending(path: try #require(second.audioFilename))
    try Data("fake first audio".utf8).write(to: firstAudio)
    try Data("fake second audio".utf8).write(to: secondAudio)
    try #require(store.save(first, portraitData: png(first)))
    try #require(store.save(second, portraitData: png(second)))
    let savedFirst = try #require(store.entries.first { $0.id == first.id })
    let savedSecond = try #require(store.entries.first { $0.id == second.id })
    let firstPNG = try #require(store.snapshotURL(for: savedFirst))
    let secondPNG = try #require(store.snapshotURL(for: savedSecond))
    store.delete(first)  // Original caller has no snapshot filename; cleanup uses the saved record.
    #expect(FileManager.default.fileExists(atPath: firstPNG.path()) == false)
    #expect(FileManager.default.fileExists(atPath: firstAudio.path()) == false)
    #expect(FileManager.default.fileExists(atPath: secondPNG.path()))
    #expect(FileManager.default.fileExists(atPath: secondAudio.path()))
  }

  @Test func invalidRecipeFromDiskPreservesWholeJournal() throws {
    let dir = try directory()
    defer { try? FileManager.default.removeItem(at: dir) }
    var dream = entry()
    dream.visualRecipe?.layers[0].primitiveCount = Int.max
    let data = try JSONEncoder().encode([dream])
    let file = dir.appending(path: "dreams.json")
    try data.write(to: file)
    let store = DreamStore(directory: dir)
    #expect(store.error != nil)
    #expect(store.save(entry()) == false)
    #expect(try Data(contentsOf: file) == data)
  }
  @Test func writtenFeelingEditsDoNotRedrawLegacyPortrait() {
    var legacy = DreamEntry(
      text: "A quiet room", feeling: .quiet, intensity: 0.3, reflection: "", question: "",
      usedAI: false)
    legacy.feeling = .fear
    #expect(legacy.legacyPortrait?.feeling == .quiet)
    #expect(legacy.legacyPortrait?.intensity == 0.3)
  }

  @Test func sharingUsesTheArchivedStaticPNG() async throws {
    let dir = try directory()
    defer { try? FileManager.default.removeItem(at: dir) }
    let dream = entry()
    let store = DreamStore(directory: dir)
    let recipe = try #require(dream.visualRecipe)
    let poster = try await PortraitService.shared.png(recipe: recipe)
    try #require(store.save(dream, portraitData: poster))
    let saved = try #require(store.entries.first)
    let url = try #require(store.snapshotURL(for: saved))
    let export = try await PortraitService.shared.png(recipe: recipe, snapshot: url)
    #expect(export == poster)
  }

}
