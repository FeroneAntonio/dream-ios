import Foundation

enum NarrativeCueKind: String, Codable, CaseIterable, Sendable {
  case branching, doors, crowd, connection, rising, falling, rescue, bending, fracture, repetition
  case light, emptiness, blurred, rotation, simultaneous, sceneChange, directions, drifting
}
