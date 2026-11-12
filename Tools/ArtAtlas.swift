import Foundation

@main
struct ArtAtlas {
  struct Fixture: Decodable {
    var id: String
    var text: String
    var seed: UInt64
  }
  struct Fixtures: Decodable { var dreams: [Fixture] }

  static func main() throws {
    guard CommandLine.arguments.count == 3 else {
      fatalError("Usage: atlas fixtures.json output-directory")
    }
    let fixtures = try JSONDecoder().decode(
      Fixtures.self,
      from: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])))
    let output = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
    try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
    var records: [[String: Any]] = []
    var hashes = Set<String>()
    func save(_ recipe: DreamVisualRecipe, id: String, text: String, kind: String) throws {
      let plan = try ProceduralRenderEngine.makePlan(recipe: recipe)
      guard plan.isFiniteAndBounded, hashes.insert(plan.geometryHash).inserted else {
        throw CocoaError(.coderInvalidValue)
      }
      try ProceduralRasterizer.png(plan: plan, pixels: 390)
        .write(to: output.appending(path: id + ".png"))
      try DreamVisualRecipe.encoder.encode(recipe)
        .write(to: output.appending(path: id + ".json"))
      records.append([
        "id": id, "text": text, "kind": kind,
        "family": recipe.layers[0].family.rawValue, "seed": String(recipe.seed),
        "why": recipe.why, "hash": plan.geometryHash,
        "marks": plan.marks.count, "points": plan.pointCount,
      ])
    }
    for fixture in fixtures.dreams {
      let features = NarrativeVisualAnalyzer.local(fixture.text)
      for variant in 0..<8 {
        let seed = try seedCoveringStudy(
          variant % 6, near: fixture.seed &+ UInt64(variant) &* 104729)
        let recipe = VisualRuleEngine.compose(features: features, seed: seed)
        try save(recipe, id: "\(fixture.id)-\(variant+1)", text: fixture.text, kind: "narrative")
      }
      print(fixture.id, "8 narrative studies")
    }
    for (familyIndex, family) in VisualFamily.allCases.enumerated() {
      for variant in 0..<8 {
        let seed = try seedCoveringStudy(
          variant % 6, near: UInt64(900001 + familyIndex * 1087 + variant * 104729))
        var recipe = VisualRuleEngine.compose(
          features: NarrativeVisualAnalyzer.local(""), seed: seed)
        recipe.layers = [
          VisualLayer(
            family: family,
            primitiveCount: family == .branchingPaths ? 3 : (family == .constellationGraph ? 2 : 7))
        ]
        recipe.layers[0].direction = family == .flowField ? .rising : .still
        recipe.layers[0].density = 0.25 + Double(variant % 4) * 0.18
        if family == .negativeVoid { recipe.palette = .make(.inkPaper, dark: true) }
        try save(
          recipe, id: "F\(familyIndex+1)-\(variant+1)",
          text: "Technical family study: \(family.rawValue). No dream interpretation is claimed.",
          kind: "technical")
      }
    }
    let data = try JSONSerialization.data(
      withJSONObject: records, options: [.sortedKeys, .prettyPrinted])
    try data.write(to: output.appending(path: "manifest.json"))
    let cards = records.map { record in
      let id = record["id"] as! String
      let family = record["family"] as! String
      return """
        <article data-family="\(family)" data-kind="\(record["kind"]!)"><a href="\(id).png"><img loading="lazy" decoding="async" src="\(id).png" alt="\(family) · \(id)"></a><h2>\(id) · \(family)</h2><p>\(escape(record["text"] as! String))</p><details><summary>Why / recipe</summary><p>\(escape(record["why"] as! String))</p><p>Seed \(record["seed"]!) · <a href="\(id).json">Frozen recipe</a></p></details></article>
        """
    }.joined(separator: "\n")
    let options = VisualFamily.allCases.map { "<option>\($0.rawValue)</option>" }.joined()
    let html = """
      <!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>DREAM · 432 etched studies</title>
      <style>body{margin:0;background:#eee8d9;color:#24242c;font:16px/1.5 system-ui}header,main{max-width:1800px;margin:auto;padding:28px}h1{font:44px Georgia}header p{max-width:780px}label{display:inline-block;margin:0 16px 12px 0}select,input{font:inherit;padding:8px;background:#f8f4eb;border:1px solid #a79d8d}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(270px,1fr));gap:30px}article[hidden]{display:none}img{width:100%;aspect-ratio:1;display:block}h2{font-size:14px}article p{font-size:13px}a{color:inherit}summary{cursor:pointer}details{font-size:13px}</style></head>
      <body><header><p>DREAM / ETCHING RENDERER 3</p><h1>432 studies. Forty fictional dreams.</h1><p>320 narrative-led prints: eight seeds for each of forty distinct fictional reports. Another 112 technical studies compare fourteen geometric families. Every image uses the production Swift renderer; no AI images, Health data or private dreams.</p><label>Family <select id="family"><option value="">All families</option>\(options)</select></label><label>Series <select id="kind"><option value="">All studies</option><option value="narrative">Narrative</option><option value="technical">Technical</option></select></label><label>Search <input id="search" type="search" placeholder="Story or study ID"></label><p id="count">432 studies</p></header><main class="grid">\(cards)</main>
      <script>const cards=[...document.querySelectorAll('article')],family=document.getElementById('family'),kind=document.getElementById('kind'),search=document.getElementById('search');function filter(){let count=0;for(const card of cards){card.hidden=(family.value&&card.dataset.family!==family.value)||(kind.value&&card.dataset.kind!==kind.value)||(search.value&&!card.textContent.toLowerCase().includes(search.value.toLowerCase()));if(!card.hidden)count++}document.getElementById('count').textContent=count+' studies'}for(const id of ['family','kind','search'])document.getElementById(id).addEventListener('input',filter);</script></body></html>
      """
    try Data(html.utf8).write(to: output.appending(path: "index.html"))
    print(records.count, "distinct bounded compositions exported")
  }
  // The comparison matrix deliberately exercises all six studies, not lucky seeds.
  static func seedCoveringStudy(_ desired: Int, near base: UInt64) throws -> UInt64 {
    for offset: UInt64 in 0..<512 {
      let seed = base &+ offset
      var random = SeededRandom(seed: seed ^ 0xE7C41)
      if Int(random.next() % 6) == desired { return seed }
    }
    throw CocoaError(.coderInvalidValue)
  }
  static func escape(_ value: String) -> String {
    value.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: "\"", with: "&quot;")
  }
}
