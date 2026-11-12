import CoreGraphics
import Foundation
import ImageIO

struct PortraitImageLoader {
  @concurrent static func load(recipe: DreamVisualRecipe, snapshot: URL?, pixels: Int) async throws
    -> CGImage
  {
    let data: Data
    if let snapshot, let saved = try? Data(contentsOf: snapshot),
      CGImageSourceCreateWithData(saved as CFData, nil) != nil
    {
      data = saved
    } else {
      data = try await PortraitService.shared.png(recipe: recipe, pixels: pixels)
    }
    try Task.checkCancellation()
    guard let source = CGImageSourceCreateWithData(data as CFData, nil),
      let image = CGImageSourceCreateThumbnailAtIndex(
        source, 0,
        [
          kCGImageSourceCreateThumbnailFromImageAlways: true,
          kCGImageSourceThumbnailMaxPixelSize: pixels,
          kCGImageSourceCreateThumbnailWithTransform: true,
        ] as CFDictionary)
    else { throw CocoaError(.coderInvalidValue) }
    return image
  }
}
