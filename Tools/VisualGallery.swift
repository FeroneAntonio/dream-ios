import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

@main
struct VisualGallery {
  struct Fixture: Decodable {
    var id: String
    var seed: UInt64
    var text: String
  }
  struct Fixtures: Decodable { var dreams: [Fixture] }
  static func main() throws {
    guard CommandLine.arguments.count == 3 else {
      fatalError("Usage: gallery fixture.json output-directory")
    }
    let fixtures = try JSONDecoder().decode(
      Fixtures.self, from: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])))
    let output = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
    try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
    var cards: [String] = []
    var rows: [String] = []
    var timings: [[String: Any]] = []
    for fixture in fixtures.dreams {
      let begin = ContinuousClock.now
      let features = NarrativeVisualAnalyzer.local(fixture.text)
      let recipe = VisualRuleEngine.compose(features: features, seed: fixture.seed)
      let plan = try ProceduralRenderEngine.makePlan(recipe: recipe)
      let geometryDuration = begin.duration(to: .now)
      try DreamVisualRecipe.encoder.encode(recipe).write(
        to: output.appending(path: fixture.id + "-recipe.json"))
      for pixels in [88, 390, 1080] {
        let data = try ProceduralRasterizer.png(plan: plan, pixels: pixels)
        try data.write(to: output.appending(path: "\(fixture.id)-\(pixels).png"))
      }
      var monochrome = plan
      monochrome.background = VisualRGBA(plan.background.luminance > 0.5 ? 0xEEE8D9 : 0x171717)
      for index in monochrome.marks.indices {
        let value = monochrome.marks[index].color
        let gray = value.luminance
        let hex = UInt32(min(255, max(0, Int(gray * 255)))) * 0x010101
        monochrome.marks[index].color = VisualRGBA(hex, alpha: value.a)
      }
      try ProceduralRasterizer.png(plan: monochrome, pixels: 390).write(
        to: output.appending(path: fixture.id + "-mono.png"))
      let total = begin.duration(to: .now)
      let primary = recipe.layers.first { $0.role == .primary }!.family.rawValue
      timings.append([
        "id": fixture.id, "primary": primary, "layout": recipe.layout.rawValue,
        "geometryHash": plan.geometryHash,
        "marks": plan.marks.count, "points": plan.pointCount,
        "geometryDuration": String(describing: geometryDuration),
        "allExportsDuration": String(describing: total),
      ])
      let name = "\(fixture.id) · \(primary)"
      cards.append(
        "<article><a href='\(fixture.id)-1080.png'><img src='\(fixture.id)-390.png' alt='\(escape(recipe.accessibleDescription))'></a><h2>\(name)</h2><p>\(escape(fixture.text))</p><p class='why'>\(escape(recipe.why))</p><p><a href='\(fixture.id)-recipe.json'>Recipe</a> · \(recipe.layout.rawValue) · seed \(fixture.seed)</p><div class='small'><img src='\(fixture.id)-88.png' alt='88 pixel thumbnail'><img src='\(fixture.id)-mono.png' alt='Monochrome comparison'></div></article>"
      )
      let evidence = recipe.decisions.compactMap(\.evidenceExcerpt).joined(separator: "; ")
      rows.append(
        "| \(fixture.id) | \(evidence) | \(primary) + \(recipe.layers.dropFirst().map { $0.family.rawValue }.joined(separator:", ")) | \(recipe.layout.rawValue) |"
      )
      print(
        fixture.id, primary, recipe.layout.rawValue, "geometry", geometryDuration, "all exports",
        total)
    }
    // One additional standalone composition per family, all from the same renderer.
    for (index, family) in VisualFamily.allCases.enumerated() {
      let seed = UInt64(900 + index)
      var recipe = VisualRuleEngine.compose(features: NarrativeVisualAnalyzer.local(""), seed: seed)
      recipe.layers = [
        VisualLayer(
          family: family,
          primitiveCount: family == .constellationGraph ? 5 : (family == .branchingPaths ? 3 : 7))
      ]
      recipe.layers[0].direction = family == .flowField ? .rising : .still
      let theme: VisualPalette
      switch family {
      case .chromaticHaze, .flowField: theme = .chromaticHaze
      case .spiralImprint, .warpedBands, .nestedEchoes, .thresholdRooms, .negativeVoid:
        theme = .inkPaper
      case .angularRays, .layeredCollage: theme = .acidDream
      case .constellationGraph, .interferenceWaves: theme = .nightPrint
      case .branchingPaths, .fracturedCells, .particleField: theme = .mutedMemory
      }
      recipe.palette = .make(
        theme, dark: [.negativeVoid, .chromaticHaze, .constellationGraph].contains(family))
      let plan = try ProceduralRenderEngine.makePlan(recipe: recipe)
      try ProceduralRasterizer.png(plan: plan, pixels: 390).write(
        to: output.appending(path: "family-\(family.rawValue).png"))
    }
    try montage(
      output: output, files: fixtures.dreams.map { $0.id + "-390.png" },
      labels: fixtures.dreams.map(\.id), size: 390, name: "comparison.png")
    try montage(
      output: output, files: fixtures.dreams.map { $0.id + "-mono.png" },
      labels: fixtures.dreams.map(\.id), size: 390, name: "monochrome-comparison.png")
    try montage(
      output: output, files: fixtures.dreams.map { $0.id + "-88.png" },
      labels: fixtures.dreams.map(\.id), size: 88, name: "thumbnails-88.png")
    try montage(
      output: output, files: VisualFamily.allCases.map { "family-\($0.rawValue).png" },
      labels: VisualFamily.allCases.map(\.rawValue), size: 230, name: "all-families.png")
    let html = """
      <!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>DREAM · Visual Grammar 1.0</title>
      <style>body{margin:0;background:#eee8d9;color:#25242b;font:16px/1.6 system-ui}header,main,footer{max-width:1440px;margin:auto;padding:32px}h1{font:48px Georgia;margin:0}header p{max-width:800px}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:28px}article{min-width:0}article>a>img{width:100%;aspect-ratio:1}h2{font:21px Georgia}p{font-size:14px}.why{font-family:Georgia;font-size:16px}a{color:inherit}.small{display:flex;gap:12px;align-items:center}.small img:first-child{width:88px}.small img:last-child{width:140px}.families{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px}.families img{width:100%}</style>
      <header><p>DREAM / PROCEDURAL PRINTS / GRAMMAR 1.0</p><h1>Eight stories, eight prints.</h1><p>Synthetic stories, fixed seeds. Local literal narrative analysis; no AI image generator, language model, DReAMy or Health data used in this gallery. The geometry and Core Graphics renderer are shared with the iOS app. Click a print for the 1080 px export; each card includes the 88 px thumbnail and a monochrome comparison.</p></header><main><div class="grid">\(cards.joined())</div><h2>The fourteen families</h2><div class="families">\(VisualFamily.allCases.map { "<figure><img src='family-\($0.rawValue).png' alt='\($0.label)'><figcaption>\($0.rawValue)</figcaption></figure>" }.joined())</div></main><footer>Engineering parity and creative fixtures, not psychological ground truth. The seed varies details inside story-led constraints.</footer></html>
      """
    try Data(html.utf8).write(to: output.appending(path: "index.html"))
    try JSONSerialization.data(withJSONObject: timings, options: [.prettyPrinted, .sortedKeys])
      .write(to: output.appending(path: "render-measurements-macos.json"))
    let mapping =
      "# Synthetic narrative → rule → composition\n\n| Dream | Verified excerpts | Geometry | Layout |\n| --- | --- | --- | --- |\n"
      + rows.joined(separator: "\n")
      + "\n\nSources: literal local narrative rules determine topology; palette and finish are artistic presets; fixed seed controls geometric details. DReAMy, Foundation Models, user corrections and Health are not used in this gallery.\n"
    try Data(mapping.utf8).write(to: output.appending(path: "NARRATIVE_MAPPING.md"))
  }
  static func montage(output: URL, files: [String], labels: [String], size: Int, name: String)
    throws
  {
    let gap = 18
    let caption = 30
    let columns = 4
    let rows = (files.count + 3) / 4
    let width = columns * (size + gap) + gap
    let height = rows * (size + gap + caption) + gap
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    let context = CGContext(
      data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
      space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.setFillColor(CGColor(srgbRed: 0.933, green: 0.910, blue: 0.851, alpha: 1))
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    for index in files.indices {
      let source = CGImageSourceCreateWithURL(output.appending(path: files[index]) as CFURL, nil)!
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil)!
      let x = gap + (index % columns) * (size + gap)
      let y = height - gap - (index / columns) * (size + gap + caption) - size
      context.draw(image, in: CGRect(x: x, y: y, width: size, height: size))
      let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): CTFontCreateWithName(
          "Helvetica" as CFString, 12, nil),
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): CGColor(
          gray: 0.15, alpha: 1),
      ]
      let line = CTLineCreateWithAttributedString(
        NSAttributedString(string: labels[index], attributes: attributes))
      context.textPosition = CGPoint(x: x, y: y - 21)
      CTLineDraw(line, context)
    }
    let data = NSMutableData()
    let destination = CGImageDestinationCreateWithData(
      data, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, context.makeImage()!, nil)
    guard CGImageDestinationFinalize(destination) else { throw CocoaError(.coderInvalidValue) }
    try (data as Data).write(to: output.appending(path: name))
  }
  static func escape(_ value: String) -> String {
    value.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: "\"", with: "&quot;")
  }
}
