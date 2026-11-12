#if DEBUG
  import Foundation

  /// Explicit synthetic-only device check. Never reads the diary, Health or audio.
  @MainActor
  enum VisualGrammarProbe {
    struct Fixture: Decodable {
      var id: String
      var seed: UInt64
      var text: String
    }
    struct Fixtures: Decodable { var dreams: [Fixture] }
    static func runIfRequested() async {
      guard ProcessInfo.processInfo.arguments.contains("--verify-visual-grammar") else { return }
      let folder = URL.documentsDirectory.appending(
        path: "visual-grammar-qa", directoryHint: .isDirectory)
      do {
        guard let source = Bundle.main.url(forResource: "fictional_dreams", withExtension: "json")
        else { return }
        let fixtures = try JSONDecoder().decode(Fixtures.self, from: Data(contentsOf: source))
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        var measurements: [[String: Any]] = []
        for fixture in fixtures.dreams {
          let begin = ContinuousClock.now
          let recipe = VisualRuleEngine.compose(
            features: NarrativeVisualAnalyzer.local(fixture.text), seed: fixture.seed)
          let data = try await PortraitService.shared.png(recipe: recipe)
          let elapsed = begin.duration(to: .now)
          try data.write(
            to: folder.appending(path: fixture.id + ".png"),
            options: [.atomic, .completeFileProtection])
          measurements.append([
            "id": fixture.id, "geometryAndPNG": String(describing: elapsed), "bytes": data.count,
            "seed": fixture.seed, "family": recipe.layers[0].family.rawValue,
          ])
        }
        let report: [String: Any] = [
          "status": "complete", "synthetic": true, "pixels": 1080, "grammarVersion": 1,
          "rendererVersion": 2,
          "systemVersion": ProcessInfo.processInfo.operatingSystemVersionString,
          "measurements": measurements,
          "note":
            "Cold or cached render duration; not frame cadence, peak memory or scientific model accuracy. No models or health data used.",
        ]
        let data = try JSONSerialization.data(
          withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
        try data.write(
          to: folder.appending(path: "report.json"), options: [.atomic, .completeFileProtection])
        if ProcessInfo.processInfo.arguments.contains("--verify-visual-interpretation"),
          let fixture = fixtures.dreams.first
        {
          let composer = DreamComposer(recoverDraft: false)
          composer.text = fixture.text
          let begin = ContinuousClock.now
          await composer.create()
          let result = composer.result
          let report: [String: Any] = [
            "synthetic": true, "fixture": fixture.id,
            "status": result == nil ? "failed" : "complete",
            "usedAppleIntelligence": result?.usedAI ?? false,
            "dreamyAvailable": result?.emotions?.isValid ?? false,
            "dreamyLabels": result?.emotions?.summary ?? "",
            "hasRecipe": result?.visualRecipe?.isValid ?? false,
            "primary": result?.visualRecipe?.layers.first?.family.rawValue ?? "",
            "why": result?.visualRecipe?.why ?? "",
            "title": result?.title ?? "", "reading": result?.reflection ?? "",
            "question": result?.question ?? "",
            "duration": String(describing: begin.duration(to: .now)),
            "note":
              "Fixed fictional report; no diary entry created, no microphone or Health access.",
          ]
          let data = try JSONSerialization.data(
            withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
          try data.write(
            to: folder.appending(path: "interpretation-report.json"),
            options: [.atomic, .completeFileProtection])
        }
      } catch {
        if let data = try? JSONSerialization.data(withJSONObject: [
          "status": "failed", "error": error.localizedDescription,
        ]) {
          try? data.write(
            to: folder.appending(path: "report.json"), options: [.atomic, .completeFileProtection])
        }
      }
    }
  }
#endif
