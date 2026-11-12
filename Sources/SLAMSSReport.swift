import Foundation

struct SLAMSSReport: Codable, Hashable {
    var schemaVersion: Int
    var model: SLAMSSProvenance
    var recordingStart: Date
    var epochSeconds: Int
    var probabilities: [[Double]]

    enum CodingKeys: String, CodingKey {
        case model, probabilities
        case schemaVersion = "schema_version", recordingStart = "recording_start", epochSeconds = "epoch_seconds"
    }
    static let upstreamCommit = "088e363873b4ac5b27bc23fb038abc052889698c"
    static let preprocessing = "upstream-prepared-mat-v1"

    var end: Date { recordingStart.addingTimeInterval(Double(probabilities.count) * Double(epochSeconds)) }

    func validate(for dreamDate: Date) throws {
        guard !model.synthetic else { throw SLAMSSImportError.synthetic }
        guard schemaVersion == 1, model.name == "SLAMSS-IFS", model.upstreamCommit == Self.upstreamCommit,
              model.preprocessing == Self.preprocessing, model.validation == "research-unvalidated-in-DREAM",
              Self.isHash(model.cnnSHA256), Self.isHash(model.sequenceSHA256),
              let source = URL(string: model.weightsSource), ["https", "http"].contains(source.scheme),
              SleepStage.modelOrder.map(\.rawValue).contains(model.initialStage),
              !model.initialStageBasis.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              epochSeconds == 30, !probabilities.isEmpty,
              probabilities.count <= 1200, recordingStart.timeIntervalSince1970.isFinite else {
            throw SLAMSSImportError.invalidReport
        }
        for scores in probabilities {
            guard scores.count == 4, scores.allSatisfy({ $0.isFinite && (0...1).contains($0) }),
                  abs(scores.reduce(0, +) - 1) <= 0.0001 else { throw SLAMSSImportError.invalidReport }
        }
        guard end <= dreamDate.addingTimeInterval(300), end >= dreamDate.addingTimeInterval(-18 * 3600),
              recordingStart >= dreamDate.addingTimeInterval(-36 * 3600) else { throw SLAMSSImportError.wrongNight }
    }

    func timeline(for dreamDate: Date) throws -> SleepTimeline {
        try validate(for: dreamDate)
        let intervals = probabilities.enumerated().map { index, scores in
            let maximum = scores.max() ?? 0
            let winners = scores.indices.filter { scores[$0] == maximum }
            let stage = winners.count == 1 ? SleepStage.modelOrder[winners[0]] : .unknown
            let start = recordingStart.addingTimeInterval(Double(index * 30))
            return SleepInterval(start: start, end: start.addingTimeInterval(30), stage: stage)
        }
        return SleepTimeline(source: .slamssIFS, intervals: intervals)
    }

    @concurrent static func read(from url: URL, for dreamDate: Date) async throws -> Self {
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        let data = try handle.read(upToCount: 2_000_001) ?? Data()
        guard data.count <= 2_000_000 else { throw SLAMSSImportError.tooLarge }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let report = try decoder.decode(Self.self, from: data)
        try report.validate(for: dreamDate)
        return report
    }

    private static func isHash(_ value: String) -> Bool {
        value.count == 64 && value.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
    }
}
