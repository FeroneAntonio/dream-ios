import SwiftUI

struct NightSummary: View {
    var night: NightContext
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(night.start, format: .dateTime.day().month().hour().minute())
            LabeledContent("Recorded sleep", value: "\(night.hours.formatted(.number.precision(.fractionLength(1)))) hours")
            if let pulse = night.heartRate {
                LabeledContent("Average sampled heart rate", value: "\(pulse.formatted(.number.precision(.fractionLength(0)))) bpm")
                Text("\(night.sampleCount) samples available").font(.footnote).foregroundStyle(Color("SecondaryInk"))
            } else { Text("Heart rate unavailable").foregroundStyle(Color("SecondaryInk")) }
            if let timeline = night.healthSleep { SleepTimelineView(timeline: timeline) }
        }
    }
}
