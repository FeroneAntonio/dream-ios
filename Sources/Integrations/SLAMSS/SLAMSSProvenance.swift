import Foundation

struct SLAMSSProvenance: Codable, Hashable {
  var name: String
  var upstreamCommit: String
  var preprocessing: String
  var cnnSHA256: String
  var sequenceSHA256: String
  var weightsSource: String
  var initialStage: String
  var initialStageBasis: String
  var validation: String
  var synthetic: Bool

  enum CodingKeys: String, CodingKey {
    case name, preprocessing, validation, synthetic
    case upstreamCommit = "upstream_commit"
    case cnnSHA256 = "cnn_sha256"
    case sequenceSHA256 = "sequence_sha256"
    case weightsSource = "weights_source"
    case initialStage = "initial_stage"
    case initialStageBasis = "initial_stage_basis"
  }
}
