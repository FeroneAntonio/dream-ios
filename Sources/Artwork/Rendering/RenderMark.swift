import Foundation

struct RenderMark: Codable, Hashable, Sendable {
  var kind: RenderMarkKind
  var points: [RenderPoint]
  var color: VisualRGBA
  var width: Double = 0.0015
  var radiusX: Double = 0
  var radiusY: Double = 0
  var closed = false
}
