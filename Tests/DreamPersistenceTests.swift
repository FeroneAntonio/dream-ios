import Foundation
import Testing
@testable import DREAM

@MainActor
struct DreamPersistenceTests {
    private func directory() throws -> URL {
        let url = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
    private func entry() -> DreamEntry {
        DreamEntry(text: "Camminavo in una città di carta.", feeling: .wonder, intensity: 0.7,
                   reflection: "Un ricordo immaginario.", question: "Cosa ti ricorda?", usedAI: false)
    }

    @Test func draftSurvivesReopening() throws {
        let dir = try directory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let draft = DreamDraft(text: "Un ponte tra le nuvole", feeling: .confusion, intensity: 0.8)
        try DreamDraftStore(directory: dir).save(draft)
        let reopened = DreamDraftStore(directory: dir)
        #expect(try reopened.load() == draft)
    }

    @Test func emptyDraftDoesNotRestoreAnOldDream() throws {
        let dir = try directory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let drafts = DreamDraftStore(directory: dir)
        try drafts.save(DreamDraft(text: "Un ricordo"))
        try drafts.save(DreamDraft(text: " \n "))
        #expect(try drafts.load() == nil)
    }

    @Test func editingReplacesTheSameDreamAndPersists() throws {
        let dir = try directory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = DreamStore(directory: dir)
        var dream = entry()
        try #require(store.save(dream))
        dream.text = "La città di carta si apriva sul mare."
        dream.title = "La città e il mare"
        try #require(store.save(dream))
        let reopened = DreamStore(directory: dir)
        #expect(reopened.entries.count == 1)
        #expect(reopened.entries.first == dream)
    }

    @Test func olderDiaryWithoutTitleCanStillBeRead() throws {
        let dir = try directory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let original = entry()
        let data = try JSONEncoder().encode([original])
        // The original 0.1 format has no title key.
        try data.write(to: dir.appending(path: "dreams.json"))
        let store = DreamStore(directory: dir)
        #expect(store.error == nil)
        #expect(store.entries.first?.displayTitle == original.text)
    }

    @Test func unreadableDiaryIsNeverOverwritten() throws {
        let dir = try directory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appending(path: "dreams.json")
        let damaged = Data("incomplete-json".utf8)
        try damaged.write(to: file)
        let store = DreamStore(directory: dir)
        #expect(store.save(entry()) == false)
        #expect(try Data(contentsOf: file) == damaged)
    }

    @Test func deletedDreamDoesNotReturnOnRelaunch() throws {
        let dir = try directory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = DreamStore(directory: dir)
        let dream = entry()
        try #require(store.save(dream))
        store.delete(dream)
        #expect(DreamStore(directory: dir).entries.isEmpty)
    }

    @Test func voiceRecordingCanBeSavedWithoutTranscriptAndDeleted() throws {
        let dir = try directory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let bytes = Data("synthetic-audio-fixture".utf8)
        try bytes.write(to: dir.appending(path: "voice-draft.m4a"))
        let voice = DreamVoice(directory: dir)
        try #require(voice.hasRecording)
        var dream = entry()
        dream.text = ""
        dream.audioFilename = try voice.preserveRecording(for: dream.id)
        let filename = try #require(dream.audioFilename)
        let audio = dir.appending(path: "audio").appending(path: filename)
        #expect(try Data(contentsOf: audio) == bytes)
        let store = DreamStore(directory: dir)
        try #require(store.save(dream))
        #expect(DreamStore(directory: dir).entries.first?.audioFilename == filename)
        store.delete(dream)
        #expect(FileManager.default.fileExists(atPath: audio.path()) == false)
    }
}
