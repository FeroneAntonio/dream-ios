import Charts
import SwiftUI

struct SleepTimelineView: View {
  var timeline: SleepTimeline
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(
        timeline.source == .appleHealth
          ? "Apple Health sleep stages" : "SLAMSS-IFS · research estimate"
      )
      .font(.headline)
      Chart(timeline.intervals) { interval in
        RectangleMark(
          xStart: .value("Start", interval.start), xEnd: .value("End", interval.end),
          y: .value("Stage", interval.stage.label)
        )
        .foregroundStyle(interval.stage.color)
      }
      .chartYScale(domain: ["Deep", "Light", "REM", "Awake", "Unclassified"])
      .chartXAxis {
        AxisMarks(values: .automatic(desiredCount: 3)) { _ in
          AxisValueLabel(format: .dateTime.hour().minute())
        }
      }
      .frame(height: 165)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(
        timeline.source == .appleHealth
          ? "Apple Health sleep stages" : "Research sleep stage estimates"
      )
      .accessibilityValue(timeline.summary)
      Text(timeline.summary).font(.footnote).foregroundStyle(Color("SecondaryInk"))
      if timeline.source == .slamssIFS {
        Text(
          "Unvalidated in DREAM. Model scores are not calibrated certainty and do not reveal dream content."
        )
        .font(.footnote).foregroundStyle(Color("SecondaryInk"))
      }
    }
  }
}
