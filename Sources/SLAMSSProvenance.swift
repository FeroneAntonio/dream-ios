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
        case upstreamCommit = "upstream_commit", cnnSHA256 = "cnn_sha256", sequenceSHA256 = "sequence_sha256"
        case weightsSource = "weights_source", initialStage = "initial_stage", initialStageBasis = "initial_stage_basis"
    }
}
