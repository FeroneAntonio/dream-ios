import Foundation
import ImageIO
import Testing

@testable import DREAM

struct EtchingGeometryTests {
  @Test(arguments: VisualFamily.allCases)
  func eachFamilyVariesItsActualGeometryAndStaysBounded(_ family: VisualFamily) throws {
    var rawGeometry = Set<String>()
    for seed: UInt64 in [0, 1, 10, 72, 991, .max] {
      var recipe = VisualRuleEngine.compose(features: NarrativeVisualAnalyzer.local(""), seed: seed)
      recipe.layers = [VisualLayer(family: family, primitiveCount: 3)]
      var generator = EtchingGeometry(recipe: recipe, layer: recipe.layers[0])
      let marks = generator.make()
      rawGeometry.insert(DreamVisualRecipe.digest(try DreamVisualRecipe.encoder.encode(marks)))
      let first = try ProceduralRenderEngine.makePlan(recipe: recipe)
      let repeated = try ProceduralRenderEngine.makePlan(recipe: recipe)
      #expect(first == repeated)
      #expect(first.rendererVersion == 3)
      #expect(first.isFiniteAndBounded)
    }
    // This checks raw geometry before grain/pressure; grain alone cannot pass it.
    #expect(rawGeometry.count == 6)
  }

  @Test func theSavedInkRendererIsNotChangedByNewEtchings() throws {
    let url = try #require(Bundle.main.url(forResource: "visual-recipe-v2", withExtension: "json"))
    let recipe = try JSONDecoder().decode(DreamVisualRecipe.self, from: Data(contentsOf: url))
    #expect(recipe.rendererVersion == 2)
    let plan = try ProceduralRenderEngine.makePlan(recipe: recipe)
    #expect(plan.rendererVersion == 2)
    #expect(plan.geometryHash == "eb55cca542fc91b2fc260d62f8f034bbca2978229fb5e5272f0b3665a0973a4a")
  }

  @Test func additionalLayersHaveQuotedNarrativeSupport() {
    let text = "The path split into three. There were shards under a distant light."
    let recipe = VisualRuleEngine.compose(features: NarrativeVisualAnalyzer.local(text), seed: 22)
    #expect(recipe.rendererVersion == 3)
    #expect(recipe.layers.count == 3)
    #expect(recipe.layers[0].family == .branchingPaths)
    #expect(recipe.layers[0].primitiveCount == 3)
    #expect(recipe.layers.contains { $0.family == .fracturedCells })
    for decision in recipe.decisions where decision.source == .narrative {
      let quote = decision.evidenceExcerpt ?? ""
      #expect(NarrativeVisualAnalyzer.verifiedExcerpt(quote, in: text))
    }
  }

  @Test func refinementKeepsNarrativeCountsAndTravelDirection() throws {
    let original = VisualRuleEngine.compose(
      features: NarrativeVisualAnalyzer.local("I was falling and someone caught me."), seed: 22)
    for seed: UInt64 in [0, 1, 11, .max] {
      let changed = VisualRuleEngine.refining(
        original, with: .init(energy: 0.8, palette: .mutedMemory), newSeed: seed)
      #expect(changed.layers[0].direction == .falling)
      #expect(changed.layers[0].converges)
      #expect(changed.palette.name == .mutedMemory)
      #expect(changed.inputFingerprint == original.inputFingerprint)
      #expect(try ProceduralRenderEngine.makePlan(recipe: changed).isFiniteAndBounded)
    }
  }

  @Test func theAtlasContainsFortyDistinctFictionalReports() throws {
    struct Fixture: Decodable { var text: String }
    struct Collection: Decodable {
      var synthetic: Bool
      var dreams: [Fixture]
    }
    let url = try #require(Bundle.main.url(forResource: "creative_atlas", withExtension: "json"))
    let fixtures = try JSONDecoder().decode(Collection.self, from: Data(contentsOf: url))
    #expect(fixtures.synthetic)
    #expect(fixtures.dreams.count == 40)
    #expect(Set(fixtures.dreams.map(\.text)).count == 40)
  }
  @Test(arguments: VisualFamily.allCases)
  func threeDenseLayersRespectTheWholePrintBudget(_ family: VisualFamily) throws {
    var recipe = VisualRuleEngine.compose(features: NarrativeVisualAnalyzer.local(""), seed: 991)
    recipe.finish.grain = 1
    recipe.layers = [
      VisualLayer(family: family, density: 1),
      VisualLayer(family: .particleField, density: 1, seedOffset: 3, role: .secondary),
      VisualLayer(family: .chromaticHaze, density: 1, seedOffset: 7, role: .secondary),
    ]
    #expect(try ProceduralRenderEngine.makePlan(recipe: recipe).isFiniteAndBounded)
  }

  @Test func inkDepositsDoNotCollapseToOneInvisiblePoint() {
    for seed: UInt64 in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 991, .max] {
      let recipe = VisualRuleEngine.compose(features: NarrativeVisualAnalyzer.local(""), seed: seed)
      var generator = EtchingGeometry(recipe: recipe, layer: VisualLayer(family: .chromaticHaze))
      generator.attractor()
      let points = generator.drawing.marks.flatMap(\.points)
      let width = (points.map(\.x).max() ?? 0) - (points.map(\.x).min() ?? 0)
      let height = (points.map(\.y).max() ?? 0) - (points.map(\.y).min() ?? 0)
      #expect(width > 0.18 && height > 0.13)
    }
  }

}
