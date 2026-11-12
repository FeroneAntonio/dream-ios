import FoundationModels

@Generable
enum DreamTone: String {
  case calm, curious, unsettled, fearful
  var feeling: DreamFeeling {
    switch self {
    case .calm: .quiet
    case .curious: .wonder
    case .unsettled: .confusion
    case .fearful: .fear
    }
  }
}
