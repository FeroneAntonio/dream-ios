import HealthKit

@MainActor
final class HealthService {
  private let store = HKHealthStore()

  func latestNight(before referenceDate: Date = .now) async throws -> NightContext? {
    guard HKHealthStore.isHealthDataAvailable() else { return nil }
    let sleep = HKCategoryType(.sleepAnalysis)
    let heart = HKQuantityType(.heartRate)
    try await store.requestAuthorization(toShare: [], read: [sleep, heart])
    let since = referenceDate.addingTimeInterval(-36 * 3600)
    let range = HKQuery.predicateForSamples(
      withStart: since, end: referenceDate, options: .strictEndDate)
    let query = HKSampleQueryDescriptor(
      predicates: [.categorySample(type: sleep, predicate: range)],
      sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)])
    let samples = try await query.result(for: store)
    // Use one source to avoid adding overlapping records from several apps.
    let asleepValues: Set<Int> = [
      HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
      HKCategoryValueSleepAnalysis.asleepCore.rawValue,
      HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
      HKCategoryValueSleepAnalysis.asleepREM.rawValue,
    ]
    let asleep = samples.filter { asleepValues.contains($0.value) }
    guard let latest = asleep.first else { return nil }
    let source = latest.sourceRevision.source.bundleIdentifier
    let end = latest.endDate
    let nightSamples = asleep.filter {
      $0.sourceRevision.source.bundleIdentifier == source
        && $0.endDate > end.addingTimeInterval(-18 * 3600) && $0.startDate <= end
    }
    guard let start = nightSamples.map(\.startDate).min() else { return nil }
    let intervals = nightSamples.map { DateInterval(start: $0.startDate, end: $0.endDate) }.sorted {
      $0.start < $1.start
    }
    var merged: [DateInterval] = []
    for interval in intervals {
      if let last = merged.last, interval.start <= last.end {
        merged[merged.count - 1] = DateInterval(start: last.start, end: max(last.end, interval.end))
      } else {
        merged.append(interval)
      }
    }
    let pulseRange = HKQuery.predicateForSamples(
      withStart: start, end: end, options: [.strictStartDate, .strictEndDate])
    let pulseQuery = HKSampleQueryDescriptor(
      predicates: [.quantitySample(type: heart, predicate: pulseRange)], sortDescriptors: [])
    let pulses = try await pulseQuery.result(for: store)
    try Task.checkCancellation()
    let values = pulses.map {
      $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
    }
    let stages = samples.filter { $0.sourceRevision.source.bundleIdentifier == source }.compactMap {
      sample -> SleepInterval? in
      let stage: SleepStage
      switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
      case .awake: stage = .awake
      case .asleepCore: stage = .light
      case .asleepDeep: stage = .deep
      case .asleepREM: stage = .rem
      case .asleepUnspecified: stage = .unknown
      default: return nil
      }
      return SleepInterval(start: sample.startDate, end: sample.endDate, stage: stage)
    }
    let timeline = SleepTimeline.normalizedHealth(
      stages, within: DateInterval(start: start, end: end))
    return NightContext(
      start: start, end: end, hours: merged.reduce(0) { $0 + $1.duration } / 3600,
      heartRate: values.isEmpty ? nil : values.reduce(0, +) / Double(values.count),
      sampleCount: values.count,
      healthSleep: timeline)
  }
}
