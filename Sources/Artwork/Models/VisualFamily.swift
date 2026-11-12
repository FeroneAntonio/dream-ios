import Foundation

enum VisualFamily: String, Codable, CaseIterable, Sendable {
  case chromaticHaze, spiralImprint, warpedBands, nestedEchoes, angularRays, flowField,
    fracturedCells
  case constellationGraph, thresholdRooms, branchingPaths, layeredCollage, interferenceWaves,
    negativeVoid, particleField
  var label: String {
    switch self {
    case .chromaticHaze: "Soft chromatic fields"
    case .spiralImprint: "An irregular ink spiral"
    case .warpedBands: "Bent parallel bands"
    case .nestedEchoes: "Repeating nested contours"
    case .angularRays: "An asymmetric fan of rays"
    case .flowField: "Flowing paths"
    case .fracturedCells: "Separated polygon fragments"
    case .constellationGraph: "Connected ink nodes"
    case .thresholdRooms: "Overlapping open frames"
    case .branchingPaths: "Branching lines"
    case .layeredCollage: "Overlapping cut-paper planes"
    case .interferenceWaves: "Two interfering wave fields"
    case .negativeVoid: "Open space around a distant focus"
    case .particleField: "A clustered field of small marks"
    }
  }
}
