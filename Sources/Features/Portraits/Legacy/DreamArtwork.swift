import SwiftUI

struct DreamArtwork: View {
  var seed: Double
  var feeling: DreamFeeling
  var intensity: Double
  var heartRate: Double?
  var motif: DreamMotif = .orbit
  var animates = true
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    TimelineView(
      .animation(
        minimumInterval: 1.0 / 24, paused: reduceMotion || !animates || scenePhase != .active)
    ) { timeline in
      DreamCanvas(
        seed: seed, feeling: feeling, intensity: intensity, motif: motif,
        time: reduceMotion || !animates ? 0 : timeline.date.timeIntervalSinceReferenceDate,
        heartRate: heartRate)
    }
    .aspectRatio(1, contentMode: .fit)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Dream portrait. \(motif.name) with layered lines and grain.")
  }
}
