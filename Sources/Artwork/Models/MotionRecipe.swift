import Foundation

struct MotionRecipe: Codable, Hashable, Sendable {
  // V1 ships as a complete static print. Motion never changes or regenerates geometry.
  var enabled = false
  var amplitude = 0.0
  var speed = 0.1
  var isValid: Bool {
    amplitude.isFinite && (0...0.003).contains(amplitude) && speed.isFinite
      && (0...0.2).contains(speed)
  }
}
