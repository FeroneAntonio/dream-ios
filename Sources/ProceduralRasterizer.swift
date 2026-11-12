import CoreGraphics
import Foundation
import ImageIO
import Synchronization
import UniformTypeIdentifiers

struct ProceduralRasterizer {
  private static let rasterization = Mutex<Void>(())
  private static func image(plan: RenderPlan, pixels: Int) throws -> CGImage {
    guard (44...2048).contains(pixels), plan.isFiniteAndBounded,
      let space = CGColorSpace(name: CGColorSpace.sRGB),
      let context = CGContext(
        data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: pixels * 4,
        space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    else { throw CocoaError(.coderInvalidValue) }
    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)
    context.scaleBy(x: CGFloat(pixels), y: CGFloat(pixels))
    context.translateBy(x: 0, y: 1)
    context.scaleBy(x: 1, y: -1)
    context.setFillColor(color(plan.background))
    context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    context.setLineJoin(.round)
    context.setLineCap(.round)
    for mark in plan.marks {
      guard let first = mark.points.first else { continue }
      switch mark.kind {
      case .line, .polygon:
        context.beginPath()
        context.move(to: CGPoint(x: first.x, y: first.y))
        for point in mark.points.dropFirst() {
          context.addLine(to: CGPoint(x: point.x, y: point.y))
        }
        if mark.closed { context.closePath() }
        if mark.kind == .polygon {
          context.setFillColor(color(mark.color))
          context.fillPath()
        } else {
          context.setStrokeColor(color(mark.color))
          context.setLineWidth(mark.width)
          context.strokePath()
        }
      case .ellipse:
        context.setFillColor(color(mark.color))
        context.fillEllipse(
          in: CGRect(
            x: first.x - mark.radiusX, y: first.y - mark.radiusY, width: mark.radiusX * 2,
            height: mark.radiusY * 2))
      case .glow:
        guard mark.radiusX > 0, mark.radiusY > 0 else { continue }
        context.saveGState()
        context.translateBy(x: first.x, y: first.y)
        context.scaleBy(x: mark.radiusX, y: mark.radiusY)
        let colors =
          [color(mark.color), color(mark.color.opacity(0.58)), color(mark.color.opacity(0))]
          as CFArray
        if let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0, 0.36, 1]) {
          context.drawRadialGradient(
            gradient, startCenter: .zero, startRadius: 0, endCenter: .zero, endRadius: 1,
            options: [])
        }
        context.restoreGState()
      }
    }
    // Own an immutable pixel buffer rather than handing a lazily shared
    // bitmap backing store to encoders running alongside another render.
    context.flush()
    guard let bytes = context.data else { throw CocoaError(.coderInvalidValue) }
    let pixelsData = Data(bytes: bytes, count: pixels * pixels * 4)
    guard let provider = CGDataProvider(data: pixelsData as CFData),
      let image = CGImage(
        width: pixels, height: pixels, bitsPerComponent: 8, bitsPerPixel: 32,
        bytesPerRow: pixels * 4,
        space: space,
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
        provider: provider,
        decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    else { throw CocoaError(.coderInvalidValue) }
    return image
  }
  static func png(plan: RenderPlan, pixels: Int = 1080) throws -> Data {
    // One bitmap/encoder transaction at a time, including callers outside
    // the app's cache actor (gallery and concurrently scheduled tests).
    try rasterization.withLock { _ in try encode(plan: plan, pixels: pixels) }
  }
  private static func encode(plan: RenderPlan, pixels: Int) throws -> Data {
    let image = try image(plan: plan, pixels: pixels)
    let data = NSMutableData()
    guard
      let destination = CGImageDestinationCreateWithData(
        data, UTType.png.identifier as CFString, 1, nil)
    else { throw CocoaError(.coderInvalidValue) }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { throw CocoaError(.coderInvalidValue) }
    return data as Data
  }
  static func color(_ value: VisualRGBA) -> CGColor {
    CGColor(srgbRed: value.r, green: value.g, blue: value.b, alpha: value.a)
  }
}
