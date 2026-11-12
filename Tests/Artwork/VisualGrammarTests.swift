import Foundation
import ImageIO
import Testing

@testable import DREAM

struct VisualGrammarTests {
  struct Fixture: Decodable {
    var id: String
    var seed: UInt64
    var text: String
    var expectedPrimaryCandidates: [String]
    var expectedLayoutCandidates: [String]
  }
  struct Fixtures: Decodable { var dreams: [Fixture] }
  func fixtures() throws -> [Fixture] {
    let url = try #require(Bundle.main.url(forResource: "fictional_dreams", withExtension: "json"))
    return try JSONDecoder().decode(Fixtures.self, from: Data(contentsOf: url)).dreams
  }
  func recipe(_ text: String = "I remember a light", seed: UInt64 = 208) -> DreamVisualRecipe {
    VisualRuleEngine.compose(features: NarrativeVisualAnalyzer.local(text), seed: seed)
  }

  @Test func eightStoriesHaveSupportedRulesAndDistinctStructures() throws {
    var topologies = Set<VisualFamily>()
    var hashes = Set<String>()
    for fixture in try fixtures() {
      let recipe = recipe(fixture.text, seed: fixture.seed)
      #expect(recipe.isValid)
      #expect(fixture.expectedPrimaryCandidates.contains(recipe.layers[0].family.rawValue))
      #expect(fixture.expectedLayoutCandidates.contains(recipe.layout.rawValue))
      topologies.insert(recipe.layers[0].family)
      for decision in recipe.decisions
      where [.narrative, .modelSuggestion].contains(decision.source) {
        if let evidence = decision.evidenceExcerpt {
          #expect(NarrativeVisualAnalyzer.verifiedExcerpt(evidence, in: fixture.text))
        }
      }
      hashes.insert(try ProceduralRenderEngine.makePlan(recipe: recipe).geometryHash)
    }
    #expect(topologies.count >= 6)
    #expect(hashes.count == 8)
  }

  @Test(arguments: VisualFamily.allCases)
  func everyFamilyIsBoundedAndRepeatable(_ family: VisualFamily) throws {
    var recipe = recipe()
    recipe.layers = [VisualLayer(family: family)]
    let first = try ProceduralRenderEngine.makePlan(recipe: recipe)
    let second = try ProceduralRenderEngine.makePlan(recipe: recipe)
    #expect(first.isFiniteAndBounded)
    #expect(first == second)
    #expect(first.geometryHash == second.geometryHash)
    let png = try ProceduralRasterizer.png(plan: first, pixels: 88)
    let repeatedPNG = try ProceduralRasterizer.png(plan: second, pixels: 88)
    let source = try #require(CGImageSourceCreateWithData(png as CFData, nil))
    let repeatedSource = try #require(CGImageSourceCreateWithData(repeatedPNG as CFData, nil))
    let image = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
    let repeatedImage = try #require(CGImageSourceCreateImageAtIndex(repeatedSource, 0, nil))
    let pixels = try #require(image.dataProvider?.data) as Data
    let repeatedPixels = try #require(repeatedImage.dataProvider?.data) as Data
    #expect(pixels == repeatedPixels)
    #expect(image.width == 88 && image.height == 88)
  }

  @Test func recipeRoundTripAndChangedSeedKeepMeaning() throws {
    let original = recipe("The path split into three.", seed: .max)
    let decoded = try JSONDecoder().decode(
      DreamVisualRecipe.self, from: DreamVisualRecipe.encoder.encode(original))
    #expect(decoded == original)
    #expect(decoded.identity == original.identity)
    let explored = VisualRuleEngine.refining(original, with: .init(), newSeed: 1)
    #expect(explored.layers[0].family == original.layers[0].family)
    #expect(explored.layers[0].primitiveCount == 3)
    #expect(explored.inputFingerprint == original.inputFingerprint)
    #expect(explored.seed != original.seed)
    #expect(
      try ProceduralRenderEngine.makePlan(recipe: explored).geometryHash
        != ProceduralRenderEngine.makePlan(recipe: original).geometryHash)
    #expect(original.seed == .max)
  }

  @Test func fabricatedEvidenceAndUnsupportedCountsAreDiscarded() {
    let text = "I remember a light."
    let local = NarrativeVisualAnalyzer.local(text)
    let combined = NarrativeVisualAnalyzer.merging(
      [
        NarrativeCue(kind: .fracture, excerpt: "the tower exploded", count: 1),
        NarrativeCue(kind: .branching, excerpt: "light", count: 10000),
      ], into: local, text: text)
    #expect(combined.cues == local.cues)
    #expect(recipe("There were no doors.").layers[0].family != .thresholdRooms)
  }

  @Test func aLanguageModelCannotOverrideLiteralStructure() {
    let text = "I was falling. I saw a light."
    let local = NarrativeVisualAnalyzer.local(text)
    let model = NarrativeVisualAnalyzer.merging(
      [NarrativeCue(kind: .branching, excerpt: "a light", count: 3)], into: local, text: text)
    let result = VisualRuleEngine.compose(features: model, seed: 1)
    #expect(result.layers[0].family == .flowField)
  }

  @Test func independentEmotionHintsDoNotChooseTopologyAndUserChoicesWin() {
    let features = NarrativeVisualAnalyzer.local("The path split into three.")
    let plain = VisualRuleEngine.compose(features: features, seed: 1)
    let hints = VisualRuleEngine.compose(
      features: features, emotionHints: [.anger, .apprehension, .happiness, .confusion, .sadness],
      emotionHintsTruncated: true, seed: 1)
    #expect(hints.layers == plain.layers)
    #expect(hints.palette == plain.palette)
    #expect(hints.decisions.filter { $0.source == .dreamyHint }.count == 5)
    #expect(
      hints.decisions.filter { $0.source == .dreamyHint }.allSatisfy {
        $0.detail.contains("beginning")
      })
    #expect(hints.finish.edgeRoughness > plain.finish.edgeRoughness)
    #expect(hints.finish.grain > plain.finish.grain)
    let user = UserVisualAdjustments(energy: 0.1, palette: .acidDream)
    let refined = VisualRuleEngine.refining(hints, with: user)
    let refinedPlain = VisualRuleEngine.refining(plain, with: user)
    #expect(refined.finish == refinedPlain.finish)
    #expect(refined.palette.name == .acidDream)
    #expect(refined.layers == refinedPlain.layers)
    #expect(refined.decisions.filter { $0.source == .dreamyHint }.allSatisfy { $0.overridden })
  }

  @Test func invalidRecipeAndExportSizesCannotReachDrawingLoops() {
    var invalid = recipe()
    invalid.layers[0].density = .infinity
    #expect(throws: CocoaError.self) { try ProceduralRenderEngine.makePlan(recipe: invalid) }
    invalid = recipe()
    invalid.layers[0].primitiveCount = Int.max
    #expect(throws: CocoaError.self) { try ProceduralRenderEngine.makePlan(recipe: invalid) }
    invalid = recipe()
    invalid.layers = []
    #expect(throws: CocoaError.self) { try ProceduralRenderEngine.makePlan(recipe: invalid) }
    #expect(throws: CocoaError.self) {
      try ProceduralRasterizer.png(
        plan: RenderPlan(background: .init(0), marks: []), pixels: 100000)
    }
  }

  @Test func exportThumbnailAndPreviewUseIdenticalNormalizedGeometry() throws {
    let plan = try ProceduralRenderEngine.makePlan(
      recipe: recipe("The streets bent sideways.", seed: 206))
    let hash = plan.geometryHash
    for size in [88, 390, 1080] {
      let data = try ProceduralRasterizer.png(plan: plan, pixels: size)
      let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
      let image = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
      #expect(image.width == size && image.height == size)
      #expect(plan.geometryHash == hash)
    }
  }

  @Test @MainActor func fallbackWorksWithoutModelsOrHealthAndPreservesPersonalSelections()
    async throws
  {
    let composer = DreamComposer(recoverDraft: false)
    composer.text = "I remember a light"
    composer.feeling = .quiet
    composer.intensity = 0.17
    await composer.create(useAI: false)
    let result = try #require(composer.result)
    #expect(result.usedAI == false)
    #expect(result.night == nil)
    #expect(result.feeling == .quiet && result.intensity == 0.17)
    #expect(result.visualRecipe?.isValid == true)
    let empty = DreamComposer(recoverDraft: false)
    empty.text = " \n "
    await empty.create(useAI: false)
    #expect(empty.result == nil)
    #expect(empty.unassistedEntry().visualRecipe == nil)
    #expect(recipe("").isValid)
  }
  @Test func movementAndEmptySpaceDoNotInventDirectionsOrLights() {
    let swimming = recipe("I was swimming.")
    #expect(swimming.layers[0].direction == .crossing)
    #expect(swimming.why.contains("upward") == false)
    let empty = recipe("I was completely alone.")
    #expect(empty.layers[0].family == .negativeVoid)
    #expect(empty.layers[0].hasFocus == false)
    #expect(empty.accessibleDescription.contains("distant focus") == false)
  }

  @Test func firstInstalledRecipeRetainsItsIdentityAndRenderer() throws {
    let url = try #require(Bundle.main.url(forResource: "visual-recipe-v1", withExtension: "json"))
    let original = try JSONDecoder().decode(DreamVisualRecipe.self, from: Data(contentsOf: url))
    #expect(original.rendererVersion == nil)
    #expect(original.identity == "06d27c2b606f1b3ddcbeac84b641fa25873593be2d8042886c40444153000f9d")
    let plan = try ProceduralRenderEngine.makePlan(recipe: original)
    #expect(plan.rendererVersion == 1)
    #expect(plan.geometryHash == "c3a23c957d0b692a8ab453847ad7e80ae51bdec441f6b3081703d81e19db4cfd")
    var refined = original
    refined.rendererVersion = 2
    let penPlan = try ProceduralRenderEngine.makePlan(recipe: refined)
    #expect(penPlan.rendererVersion == 2)
    #expect(penPlan.geometryHash != plan.geometryHash)
    #expect(original.rendererVersion == nil)
  }

}
