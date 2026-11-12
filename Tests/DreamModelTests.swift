import Foundation
import Testing
@testable import DREAM

struct DreamModelTests {
    @Test func independentEmotionsCanCoexistAndHalfIsNotPresent() throws {
        let analysis = try DreamEmotionAnalysis(logits: [2, 2, 0, -2, -2], truncated: false)
        #expect(analysis.present == [.anger, .apprehension])
        #expect(analysis.scores.reduce(0, +) > 2)
        #expect(throws: CocoaError.self) { try DreamEmotionAnalysis(logits: [0, .nan, 0, 0, 0], truncated: false) }
    }
    @Test func artisticMappingHasAnExplicitReason() throws {
        let analysis = try DreamEmotionAnalysis(logits: [-2, -2, -2, 2, -2], truncated: false)
        #expect(analysis.suggestedMotif == .fragment)
        #expect(analysis.visualExplanation.contains("confusion"))
    }

    @Test func tokenizerAndNativeModelMatchOriginalFixtures() async throws {
        let bundle = Bundle.main
        let vocabURL = try #require(bundle.url(forResource: "dreamy-vocab", withExtension: "txt"))
        let fixturesURL = try #require(bundle.url(forResource: "dreamy-test-vectors", withExtension: "json"))
        let tokenizer = try DreamBERTTokenizer(vocabulary: String(contentsOf: vocabURL, encoding: .utf8))
        let data = try JSONSerialization.jsonObject(with: Data(contentsOf: fixturesURL)) as? [String: Any]
        let fixtures = try #require(data?["fixtures"] as? [[String: Any]])
        for fixture in fixtures {
            let text = try #require(fixture["text"] as? String)
            let ids = try #require(fixture["token_ids"] as? [Int])
            let tokens = tokenizer.encode(text)
            #expect(tokens.ids.map(Int.init) == ids)
            #expect(tokens.ids.count == 512)
            if let expected = fixture["scores"] as? [Double] {
                let analysis = try await DreamEmotionAnalyzer.analyze(text)
                for index in 0..<5 { #expect(abs(analysis.scores[index] - expected[index]) < 0.02) }
            }
        }
        let long = tokenizer.encode(String(repeating: "dream ", count: 600))
        #expect(long.truncated)
        #expect(long.ids[511] == 102)
        #expect(long.mask.allSatisfy { $0 == 1 })
    }
}
