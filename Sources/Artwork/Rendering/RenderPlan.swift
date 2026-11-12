import Foundation

struct RenderPlan: Codable, Hashable, Sendable {
  var rendererVersion = 1
  var background: VisualRGBA
  var marks: [RenderMark]
  var geometryHash: String {
    DreamVisualRecipe.digest((try? DreamVisualRecipe.encoder.encode(self)) ?? Data())
  }
  var pointCount: Int { marks.reduce(0) { $0 + $1.points.count } }
  var isFiniteAndBounded: Bool {
    marks.count <= 25_000 && pointCount <= 350_000 && background.isValid
      && marks.allSatisfy { mark in
        mark.color.isValid && mark.width.isFinite && (0...0.2).contains(mark.width)
          && [mark.radiusX, mark.radiusY].allSatisfy { $0.isFinite && (0...2).contains($0) }
          && mark.points.allSatisfy {
            $0.x.isFinite && $0.y.isFinite && abs($0.x) <= 4 && abs($0.y) <= 4
          }
      }
  }
}
