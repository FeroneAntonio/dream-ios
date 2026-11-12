import SwiftUI
import UniformTypeIdentifiers

struct SLAMSSResearchSection: View {
  var report: SLAMSSReport?
  var dreamDate: Date
  var onImport: (SLAMSSReport) -> Void
  @State private var importing = false
  @State private var selection: URL?
  @State private var error: String?
  @State private var loading = false

  var body: some View {
    DisclosureGroup("Sleep research") {
      VStack(alignment: .leading, spacing: 16) {
        if let report, let timeline = try? report.timeline(for: dreamDate) {
          SleepTimelineView(timeline: timeline)
          Text("Weights source: \(report.model.weightsSource)").font(.footnote).textSelection(
            .enabled)
          Text("Starting stage: \(report.model.initialStage). \(report.model.initialStageBasis)")
            .font(.footnote).foregroundStyle(Color("SecondaryInk"))
        } else {
          Text("SLAMSS-IFS is not running on this iPhone.").font(.headline)
          Text(
            "The research code is integrated, but trained weights and validated raw-data preparation are not supplied upstream. A Health summary cannot replace the required heart-rate and wrist-motion recording."
          )
          .font(.footnote).foregroundStyle(Color("SecondaryInk"))
        }
        Button(
          "Import research estimate", systemImage: "square.and.arrow.down", action: showImporter
        )
        .frame(minHeight: 44).disabled(loading)
        if loading { ProgressView("Checking the report…") }
        if let error { Text(error).font(.footnote).foregroundStyle(.orange) }
      }.padding(.top)
    }
    .fileImporter(isPresented: $importing, allowedContentTypes: [.json], onCompletion: selectedFile)
    .task(id: selection, load)
  }

  private func showImporter() { importing = true }
  private func selectedFile(_ result: Result<URL, Error>) {
    switch result {
    case .success(let url): selection = url
    case .failure(let failure): error = failure.localizedDescription
    }
  }
  private func load() async {
    guard let selection else { return }
    loading = true
    defer {
      loading = false
      self.selection = nil
    }
    do {
      let report = try await SLAMSSReport.read(from: selection, for: dreamDate)
      try Task.checkCancellation()
      error = nil
      onImport(report)
    } catch is CancellationError {} catch { self.error = error.localizedDescription }
  }
}
