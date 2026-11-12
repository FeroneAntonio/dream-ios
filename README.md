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

- **SwiftUI** for the interface and procedural Canvas artwork.
- **AVAudioEngine**, **SpeechAnalyzer** and **SpeechTranscriber** for English live transcription and audio capture.
- **DReAMy DreamBank BERT**, converted to Core ML, for local English emotion-presence suggestions and explainable procedural motif choices.
- **Foundation Models** guided generation for title, possible interpretation, personal question and artistic parameters.
- **HealthKit** for optional sleep and sampled heart-rate context associated with an entry.
- Private local JSON persistence for the journal and draft, with atomic writes and complete iOS file protection.

The portrait uses code, not an image-generation model. Motif, palette, grain and distortion respond to the story's suggested visual tone and energy. Optional sampled heart rate affects subtle visual motion; it does not identify dream content or emotion.

`Sources/` contains the app. `Tests/` contains Swift Testing checks; `UITests/` contains XCTest UI checks. The shared Xcode scheme includes both test targets.

## Validation

Version 0.3 passed **19 automated iOS checks** (16 Swift Testing tests and 3 UI tests), covering persistence, old-format compatibility, audio-only preservation/deletion, partial transcripts, microphone-frame conversion, the capture-to-journal interface, native DReAMy parity and sleep research contracts. The external SLAMSS adapter also passed **3 Python tests**.

In the earlier prototype, on a physical iPhone 17, Apple Intelligence generated a complete reading from a fictional dream, and the English speech model correctly transcribed a synthetic recording. The audio adapter was separately checked with generated PCM samples. The new DReAMy integration has been checked on the simulator; physical-iPhone performance and final live-microphone user acceptance remain to be checked.

The model integration adds native tokenization/numerical parity, independent emotion scores, artistic mapping, sleep timeline normalization, research import validation and backward-compatible persistence tests. Conversion checks compare six synthetic stories against the original unmodified PyTorch checkpoint; these verify engineering parity, not psychological accuracy. New physical-iPhone latency and memory profiling remain to be done.

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

- [DReAMy integration](docs/DREAMY_INTEGRATION.md): actual on-device emotion annotation and model reproduction. No cloud dream-text API.
- [SLAMSS-IFS integration](docs/SLAMSS_INTEGRATION.md): genuine vendored architecture, external research inference/import and Apple Health sleep-stage timeline. **SLAMSS is not running on the iPhone**: upstream supplies no trained weights or complete raw-data preprocessing. Imported research estimates remain separate from Health data.

All new model checks use fictional/synthetic fixtures. No private dreams, Health records or recordings are published. Third-party licenses and attribution accompany both integrations.
