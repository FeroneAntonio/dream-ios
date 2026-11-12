import Foundation
import ImageIO

actor PortraitService {
  static let shared = PortraitService()
  private var cache: [String: Data] = [:]
  private var order: [String] = []

  func png(recipe: DreamVisualRecipe, pixels: Int = 1080, snapshot: URL? = nil) throws -> Data {
    try Task.checkCancellation()
    if pixels == 1080, let snapshot, let data = try? Data(contentsOf: snapshot),
      data.count <= 20_000_000,
      let source = CGImageSourceCreateWithData(data as CFData, nil),
      let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
      properties[kCGImagePropertyPixelWidth] as? Int == 1080,
      properties[kCGImagePropertyPixelHeight] as? Int == 1080
    {
      return data
    }
    let key = "\(recipe.identity)-\(pixels)"
    if let result = cache[key] { return result }
    let plan = try ProceduralRenderEngine.makePlan(recipe: recipe)
    let data = try ProceduralRasterizer.png(plan: plan, pixels: pixels)
    try Task.checkCancellation()
    cache[key] = data
    order.append(key)
    while order.count > 16 || cache.values.reduce(0, { $0 + $1.count }) > 24_000_000 {
      guard let first = order.first else { break }
      order.removeFirst()
      cache.removeValue(forKey: first)
    }
    return data
  }
}
