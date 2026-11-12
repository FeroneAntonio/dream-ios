import SwiftUI

struct PortraitRefinementView: View {
  var entry: DreamEntry
  var recreate = false
  var onConfirm: (DreamVisualRecipe) async -> Bool
  @State private var base: DreamVisualRecipe?
  @State private var preview: DreamVisualRecipe?
  @State private var energy = 0.5
  @State private var colors = VisualPalette.inkPaper
  @State private var variantSeed: UInt64?
  @State private var confirmation = 0
  @State private var saving = false
  @Environment(DreamStore.self) private var store
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          if let preview {
            RecipeArtwork(
              recipe: preview,
              snapshot: preview == entry.visualRecipe ? store.snapshotURL(for: entry) : nil,
              pixels: 780)
          } else {
            ProgressView("Preparing your print…").frame(maxWidth: .infinity, minHeight: 240)
          }
          Text("A possible shape for your story. Change it until it feels like yours.")
            .font(.body).fontDesign(.serif)
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Calmer")
              Spacer()
              Text("More intense")
            }.font(.footnote)
            Slider(value: $energy).accessibilityLabel("Visual intensity").accessibilityIdentifier(
              "portraitEnergy")
          }
          Picker("Colors", selection: $colors) {
            ForEach(VisualPalette.allCases) { palette in Text(palette.label).tag(palette) }
          }.pickerStyle(.menu).frame(minHeight: 44).accessibilityIdentifier("portraitColors")
          Button("Explore another composition", systemImage: "shuffle", action: explore)
            .frame(minHeight: 44).accessibilityIdentifier("explorePortrait")
          if let preview { Text(preview.why).font(.footnote).foregroundStyle(.secondary) }
          Text("Your saved portrait stays as it is until you choose Use portrait.")
            .font(.footnote).foregroundStyle(.secondary)
          if let error = store.error { Text(error).font(.footnote).foregroundStyle(.orange) }
        }.padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity)
      }
      .background(Color("Paper"))
      .navigationTitle("Refine portrait")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", action: cancel).disabled(saving)
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(saving ? "Saving…" : "Use portrait", action: confirm).disabled(
            preview == nil || saving
          )
          .accessibilityIdentifier("confirmPortrait")
        }
      }
      .disabled(saving)
      .interactiveDismissDisabled(saving)
      .onChange(of: energy, updatePreview)
      .onChange(of: colors, updatePreview)
      .task(prepare)
      .task(id: confirmation, save)
    }
  }
  private func prepare() async {
    let recipe: DreamVisualRecipe
    if !recreate, let existing = entry.visualRecipe {
      var upgraded = existing
      if (upgraded.rendererVersion ?? 1) < 3 {
        upgraded.rendererVersion = 3
        upgraded.decisions.append(
          VisualDecision(
            ruleID: "renderer-upgrade", source: .userChoice,
            detail: "You chose a new expressive etching study of this story."))
      }
      recipe = upgraded
    } else {
      let features = await NarrativeModelAnalyzer.analyze(entry.text, useAI: true)
      guard !Task.isCancelled else { return }
      recipe = VisualRuleEngine.compose(
        features: features, emotionHints: entry.emotions?.present ?? [],
        emotionHintsTruncated: entry.emotions?.truncated ?? false,
        user: entry.visualRecipe?.userAdjustments ?? .init(), seed: UInt64.random(in: .min ... .max)
      )
    }
    base = recipe
    energy = recipe.userAdjustments.energy ?? entry.intensity
    colors = recipe.palette.name
    preview = recipe
  }
  private func updatePreview() {
    guard let base else { return }
    preview = VisualRuleEngine.refining(
      base, with: UserVisualAdjustments(energy: energy, palette: colors), newSeed: variantSeed)
  }
  private func explore() {
    variantSeed = UInt64.random(in: .min ... .max)
    updatePreview()
  }
  private func confirm() { confirmation += 1 }
  private func cancel() { dismiss() }
  private func save() async {
    guard confirmation > 0, let preview else { return }
    saving = true
    defer { saving = false }
    if await onConfirm(preview) { dismiss() }
  }
}
