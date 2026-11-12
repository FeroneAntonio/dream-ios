import Foundation
import Testing
@testable import DREAM

struct SleepResearchTests {
    private let start = Date(timeIntervalSince1970: 1_800_000_000)
    private func report() -> SLAMSSReport {
        SLAMSSReport(schemaVersion: 1, model: SLAMSSProvenance(name: "SLAMSS-IFS", upstreamCommit: SLAMSSReport.upstreamCommit,
            preprocessing: SLAMSSReport.preprocessing, cnnSHA256: String(repeating: "a", count: 64),
            sequenceSHA256: String(repeating: "b", count: 64), weightsSource: "https://example.org/synthetic-test-fixture",
            initialStage: "awake", initialStageBasis: "Synthetic unit-test assumption only", validation: "research-unvalidated-in-DREAM", synthetic: false),
            recordingStart: start, epochSeconds: 30, probabilities: [[0.1,0.2,0.1,0.6],[0.25,0.25,0.25,0.25]])
    }

    @Test func importsKeepSourceAndTreatTiesAsUnknown() throws {
        let timeline = try report().timeline(for: start.addingTimeInterval(3600))
        #expect(timeline.source == .slamssIFS)
        #expect(timeline.intervals.map(\.stage) == [.rem, .unknown])
        #expect(timeline.intervals[0].duration == 30)
    }
    @Test func invalidOrSyntheticResearchReportsAreRejected() {
        let date = start.addingTimeInterval(3600)
        var sample = report()
        sample.model.synthetic = true
        #expect(throws: SLAMSSImportError.self) { try sample.validate(for: date) }
        sample = report(); sample.probabilities[0] = [1,1,0,0]
        #expect(throws: SLAMSSImportError.self) { try sample.validate(for: date) }
        sample = report(); sample.model.cnnSHA256 = "missing"
        #expect(throws: SLAMSSImportError.self) { try sample.validate(for: date) }
        sample = report(); sample.probabilities[0][0] = .nan
        #expect(throws: SLAMSSImportError.self) { try sample.validate(for: date) }
        #expect(throws: SLAMSSImportError.self) { try report().validate(for: date.addingTimeInterval(86400)) }
    }
    @Test func overlappingHealthStagesDoNotDoubleCountAndGapsStayUnknown() {
        func interval(_ a: Double, _ b: Double, _ stage: SleepStage) -> SleepInterval {
            SleepInterval(start: start.addingTimeInterval(a), end: start.addingTimeInterval(b), stage: stage)
        }
        let samples = [interval(0,60,.unknown), interval(0,30,.light), interval(20,40,.rem)]
        let timeline = SleepTimeline.normalizedHealth(samples, within: DateInterval(start: start, duration: 90))
        #expect(timeline.source == .appleHealth)
        #expect(timeline.intervals.map(\.duration) == [20,10,10,50])
        #expect(timeline.intervals.map(\.stage) == [.light,.unknown,.rem,.unknown])
        #expect(abs(timeline.sleepHours - 30/3600.0) < 0.00001)
    }
    @Test func originalDiaryAndNewModelResultsRoundTrip() throws {
        var entry = DreamEntry(text: "A fictional dream", feeling: .wonder, intensity: 0.5, reflection: "", question: "", usedAI: false)
        let encoder = JSONEncoder(), decoder = JSONDecoder()
        let older = try decoder.decode(DreamEntry.self, from: encoder.encode(entry))
        #expect(older.emotions == nil && older.researchSleep == nil)
        entry.researchSleep = report()
        entry.emotions = try DreamEmotionAnalysis(logits: [-2,-2,-2,2,-2], truncated: false)
        entry.night = NightContext(start: start, end: start.addingTimeInterval(60), hours: 1/60.0, sampleCount: 0,
            healthSleep: SleepTimeline(source: .appleHealth, intervals: []))
        let decoded = try decoder.decode(DreamEntry.self, from: encoder.encode(entry))
        #expect(decoded == entry)
        #expect(decoded.night?.healthSleep?.source == .appleHealth)
    }
}
