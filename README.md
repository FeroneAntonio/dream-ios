# DREAM

An iPhone prototype for capturing dreams and exploring them through a personal visual and a possible written interpretation. The interface and speech recognition are in English.

## Experience

1. **Record** or **Write**, directly in Home.
2. When recording, watch the live transcript and tap **Finish recording**.
3. Tap **Interpret dream** to generate a procedural portrait and a reading displayed beneath it.
4. Revisit the result in a notebook-style journal with paper pages, dates and handwriting-inspired typography.

Dreams can be edited, deleted and replayed. The portrait can be shared independently of the story. Draft text is recovered automatically; audio can be preserved even if transcription fails.

The reading is a tentative prompt for personal reflection, not a diagnosis or a universal decoding of symbols. The name and visual identity are provisional.

## Build and run

- Xcode **27.2**; deployment target **iOS 27.0**.
- Swift 6 language mode with strict concurrency.
- No third-party dependencies.

First run `python3 scripts/fetch_dreamy_model.py` to download and verify the genuine Core ML model release (about 200 MB). Then open `DREAM.xcodeproj` and select the **DREAM** scheme. Choose your signing team and, if necessary, your own bundle identifier. Keep the HealthKit capability enabled when signing with a different account.

Use a physical iPhone for microphone, speech, Apple Intelligence and HealthKit checks. Enable Apple Intelligence on a compatible device for generated readings. English speech assets are prepared on-device through Apple's AssetInventory; preparation may require a download.

## Implementation

- **SwiftUI** for the interface; **Core Graphics** for procedural ink/graphite prints, with the legacy Canvas renderer preserved for old entries.
- **AVAudioEngine**, **SpeechAnalyzer** and **SpeechTranscriber** for English live transcription and audio capture.
- **DReAMy DreamBank BERT**, converted to Core ML, for local English emotion-presence suggestions and small print-finish hints.
- **Foundation Models** guided generation for title, possible interpretation, personal question and separately validated narrative cues.
- **HealthKit** for optional sleep and sampled heart-rate context associated with an entry.
- Private local JSON persistence for the journal and draft, with atomic writes and complete iOS file protection.

New portraits use **Visual Grammar 1.0 / ink renderer 2**: fourteen distinct procedural families, narrative evidence, frozen recipes/seeds, pressure-varied ink and graphite hatching and **Why this drawing?**. A small **Refine portrait** preview lets the person adjust intensity/colors or explore another arrangement before confirming. Editing the story preserves the saved image until an explicit recreation. Old entries keep their legacy renderer. New V1 prints and exports are static and independent of sampled heart rate.

[Gallery comparison](docs/visual-grammar/comparison.png) · [Fourteen families](docs/visual-grammar/all-families.png) · [Architecture and reproduction](docs/VISUAL_GRAMMAR.md) · [Artist references and art direction](docs/ART_DIRECTION.md) · [Verification record](docs/VISUAL_GRAMMAR_VALIDATION.md)

[Code map and reading guide (Italian)](docs/CODE_MAP.md) and [complete Swift file index](docs/SWIFT_FILE_INDEX.md) explains each folder and the narrative-to-image pipeline.

`Sources/` contains the app, organized into features, artwork, integrations and persistence. `Tests/` contains Swift Testing checks; `UITests/` contains XCTest UI checks. The shared Xcode scheme includes both test targets.

## Validation

Version 0.5 passed **36 Swift Testing methods** (including 14 parameterized family cases), **5 UI tests**, and the unchanged SLAMSS adapter's **3 Python tests**. Coverage includes old data/voice regression, deterministic pixel rendering, safe persistence, narrative evidence, refinement confirmation/cancellation, reopening and largest Dynamic Type.

The signed app was installed and opened on a physical **iPhone 17 / iOS 27.2**. The first renderer-1 baseline produced eight synthetic 1080 px exports in approximately **25–82 ms each** in one Debug pass. The final renderer-2 ink/graphite run took approximately **26–96 ms per export**, with a successful full fictional interpretation in about **8.3 seconds**. These are single Debug passes. A fictional full interpretation also completed with DReAMy and Apple Intelligence. These are functional/elapsed-time checks, not repeated performance, peak-memory or psychological validation. The live-microphone user acceptance check, broader accessibility/device coverage and creative refinement remain to do. See the verification record for the actual commands and limitations.

Run tests with an installed iOS 27 simulator, for example:

```sh
xcodebuild -project DREAM.xcodeproj -scheme DREAM \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  CODE_SIGNING_ALLOWED=NO test
```

## Privacy and prototype limits

The app implements no remote AI provider, telemetry, application HTTP requests or cloud sync. Apple manages speech-model downloads. Standard device backup settings still apply to locally stored files.

Saved recordings remain local and are deleted with the associated dream. Starting a new recording replaces the current unsaved audio draft. Recordings are limited to two minutes. A written interpretation currently uses up to the first 5,000 characters. DReAMy uses up to 510 WordPiece content tokens, with a truncation notice; the full story remains in the journal. Non-English reports skip the English DReAMy checkpoint.

Health data is optional context. There is no independent watchOS app, nightmare detection, SpO2/HRV analysis or clinical validation.

The DEBUG-only `InterpretationProbe` can verify native models using a fixed fictional story or an explicitly supplied synthetic audio file. It is inactive on normal launch, never activates the microphone and creates no journal entry. Build products, diagnostic output, dream files and recordings are excluded from version control.

## Research integrations and creative handoff

- [Visual Grammar 1.0](docs/VISUAL_GRAMMAR.md): reproducible narrative-led prints, fourteen families, explanation and refinement.
- [DReAMy integration](docs/DREAMY_INTEGRATION.md): actual on-device emotion annotation and model reproduction. No cloud dream-text API.
- [SLAMSS-IFS integration](docs/SLAMSS_INTEGRATION.md): genuine vendored architecture, external research inference/import and Apple Health sleep-stage timeline. **SLAMSS is not running on the iPhone**: upstream supplies no trained weights or complete raw-data preprocessing. Imported research estimates remain separate from Health data.

All new model checks use fictional/synthetic fixtures. No private dreams, Health records or recordings are published. Third-party licenses and attribution accompany both integrations.
