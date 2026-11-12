import Foundation

struct NightContext: Codable, Hashable {
  var start: Date
  var end: Date
  var hours: Double
  var heartRate: Double?
  var sampleCount: Int
  var healthSleep: SleepTimeline?
}
