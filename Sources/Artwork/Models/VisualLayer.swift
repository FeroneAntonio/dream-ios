import Foundation

struct VisualLayer: Codable, Hashable, Sendable {
  var family: VisualFamily
  var anchor = NormalizedPoint(x: 0.5, y: 0.5)
  var scale = 1.0
  var rotation = 0.0
  var density = 0.5
  var order = 0.5
  var turbulence = 0.35
  var roughness = 0.4
  var opacity = 1.0
  var primitiveCount = 5
  var seedOffset: UInt64 = 0
  var role: VisualLayerRole = .primary
  var direction: VisualDirection = .still
  var converges = false
  var hasFocus = true
  var isValid: Bool {
    anchor.isValid && scale.isFinite && (0.1...1.5).contains(scale) && rotation.isFinite
      && (-Double.pi...Double.pi).contains(rotation)
      && [density, order, turbulence, roughness, opacity].allSatisfy {
        $0.isFinite && (0...1).contains($0)
      } && (1...64).contains(primitiveCount)
  }
}
