import Foundation

struct SleepTimeline: Codable, Hashable {
    enum Source: String, Codable { case appleHealth, slamssIFS }
    var source: Source
    var intervals: [SleepInterval]

    var sleepHours: Double {
        intervals.filter { $0.stage.isSleep }.reduce(0) { $0 + $1.duration } / 3600
    }
    var summary: String {
        SleepStage.allCases.compactMap { stage in
            let minutes = Int(intervals.filter { $0.stage == stage }.reduce(0) { $0 + $1.duration } / 60)
            return minutes > 0 ? "\(stage.label): \(minutes) minutes" : nil
        }.joined(separator: ", ")
    }

    // Prefer detailed labels to overlapping unspecified sleep; conflicting detailed labels stay unknown.
    static func normalizedHealth(_ samples: [SleepInterval], within window: DateInterval) -> Self {
        let clipped = samples.compactMap { sample -> SleepInterval? in
            let start = max(sample.start, window.start)
            let end = min(sample.end, window.end)
            return start < end ? SleepInterval(start: start, end: end, stage: sample.stage) : nil
        }
        let boundaries = Set(clipped.flatMap { [$0.start, $0.end] } + [window.start, window.end]).sorted()
        var intervals: [SleepInterval] = []
        for (start, end) in zip(boundaries, boundaries.dropFirst()) {
            let active = clipped.filter { $0.start <= start && $0.end >= end }
            let detailed = Set(active.map(\.stage).filter { $0 != .unknown })
            let stage: SleepStage = detailed.count == 1 ? detailed.first ?? .unknown : .unknown
            if let last = intervals.last, last.stage == stage, last.end == start {
                intervals[intervals.count - 1].end = end
            } else { intervals.append(SleepInterval(start: start, end: end, stage: stage)) }
        }
        return Self(source: .appleHealth, intervals: intervals)
    }
}
