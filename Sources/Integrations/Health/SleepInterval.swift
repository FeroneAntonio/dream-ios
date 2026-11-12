import Foundation

struct SleepInterval: Codable, Hashable, Identifiable {
  var start: Date
  var end: Date
  var stage: SleepStage
  var id: Date { start }
  var duration: TimeInterval { end.timeIntervalSince(start) }
}
