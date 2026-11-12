import FoundationModels

@Generable
enum DreamMotif: String, Codable, Hashable {
  case orbit, flow, fragment

  var name: String {
    switch self {
    case .orbit: "orbits"
    case .flow: "flow"
    case .fragment: "fragments"
    }
  }
  var frequency: Double {
    switch self {
    case .orbit: 3
    case .flow: 2
    case .fragment: 9
    }
  }
}
