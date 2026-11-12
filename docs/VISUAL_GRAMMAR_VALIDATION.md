# Visual Grammar 1.0 — verification record

12 November 2026. Xcode 27.2, iOS deployment target 27.0, strict Swift 6 mode. Version 0.5, build 9 (the first physical measurements below were taken on 0.4 / renderer 1).

## Build and automated tests

A signed Debug build succeeded for the paired **physical iPhone 17** with the existing team and bundle identifier. Installation updated `it.rowtech.dream.prototype` in place; it was not uninstalled. No journal, recordings or Health data were copied from the phone.

The iOS 27 **DREAM QA** simulator completed **36 Swift Testing methods** (including a parameterized repeat-render test over all 14 families) and **5 XCTest UI tests**. The final check covers:

- Existing DReAMy tokenizer/native numerical parity, independent sigmoid labels and legacy behavior.
- Existing JSON/draft persistence, audio preservation/deletion and microphone PCM/transcript adapter.
- Eight fallback fixtures, supported evidence, at least six primary topologies, fixed seeds, finite bounds, recipe round-trip and palette/source separation.
- Pixel-identical decoded repeat renders of each family under concurrent test scheduling; normalization/export dimensions 88, 390 and 1080.
- Invented quotations/counts rejected; language-model hints cannot outrank literal structural cues; all five emotion hints coexist without choosing topology/hue.
- Actual old-format JSON missing all new keys and `motif`; text and feeling edits preserve historical appearance.
- Snapshot reopen, archived-PNG export, atomic rollback, corrupt-journal protection and scoped snapshot/audio cleanup, including stale caller copies.
- Record permission refusal without crash; writing/draft restore; capture-to-notebook flow; largest Dynamic Type capture controls; refine preview → cancel, preview → confirm, then restart/reopen.

Command:

```sh
xcodebuild -project DREAM.xcodeproj -scheme DREAM \
  -destination 'platform=iOS Simulator,id=<DREAM-QA-simulator-id>' \
  -derivedDataPath /private/tmp/DREAM-checks \
  CODE_SIGNING_ALLOWED=NO -parallel-testing-enabled NO test
```

The unchanged external SLAMSS research adapter separately passed its **3 Python unit tests**, with random weights used only for tensor-shape smoke checks, never exported as real estimates.

## Physical iPhone rendering check — initial renderer-1 baseline

A DEBUG-only probe runs only with explicit launch arguments. It uses the eight fixed fictional fixtures and writes PNGs/reports into its own `Documents/visual-grammar-qa` folder; it does not query Health, activate the microphone or create journal entries. Only that synthetic output folder was retrieved.

Observed on iPhone 17, **iOS 27.2 (24B119)**, Debug build; one pass, 1080 × 1080 PNG:

| Fixture | Geometry + PNG |
| --- | ---: |
| D01 | 45.6 ms |
| D02 | 37.8 ms |
| D03 | 31.9 ms |
| D04 | 81.7 ms |
| D05 | 58.0 ms |
| D06 | 30.8 ms |
| D07 | 43.0 ms |
| D08 | 25.0 ms |

These are elapsed in-app geometry/PNG durations, possibly including cache/queue effects, **not** repeated benchmark distributions, UI frame cadence, peak memory or inference accuracy. The captured report is retained alongside the local gallery; native-macOS gallery timings are separately labeled and must not be quoted as iPhone results.

The physical synthetic interpretation check also completed: DReAMy available, Apple Intelligence generated a title/reading, a valid recipe was produced, and the three-path narrative selected `branchingPaths`. The first complete pipeline run took about 8.4 seconds, including models, not just rendering. The classifier suggested confusion despite the story's explicit clarity, illustrating why hints must remain fallible and must not dictate geometry. The writer prompt was tightened after reviewing that output; subsequent run evidence is kept in the local report.

## Visual review and remaining limits

The exported color montage, monochrome montage, all fourteen families and 88 px contact sheet were inspected. The eight fixtures have seven primary topologies; the two flow prints differ in travel direction, convergence and the meeting-point layer. Export/detail/thumbnail rendering share production source rather than a separate mockup renderer. UI screenshots confirmed the explanation/refinement placement and the paper notebook.

Remaining work: repeated physical-device cold/warm and memory profiling, broader stories/languages and creative iteration per family, manual VoiceOver/folding-iPhone/iPad checks, and any future opt-in motion. No new live ambient-microphone recording was made in this verification. Model interpretation remains tentative; scientific/psychological effectiveness has not been established. SLAMSS remains inactive on the iPhone for the upstream asset limitations documented separately.


## Hand-drawn revision

Renderer 2 passed the 36-method Swift suite and five UI tests. A golden recipe copied from the first installed build proves that a missing renderer-version key preserves both its original identity and render-plan hash. The final local gallery includes separate 0.4 baseline and 0.5 device reports; use the latter for current renderer timings.


## Final physical check — ink renderer 2 / version 0.5 build 9

The final iPhone 17 run completed all eight 1080 px prints with renderer 2. One-pass elapsed geometry plus PNG:

| Fixture | Geometry + PNG |
| --- | ---: |
| D01 | 76.1 ms |
| D02 | 46.4 ms |
| D03 | 62.6 ms |
| D04 | 96.4 ms |
| D05 | 75.0 ms |
| D06 | 64.2 ms |
| D07 | 41.7 ms |
| D08 | 25.5 ms |

[Raw rendering report](visual-grammar/iphone17-ink-rendering.json) · [Synthetic interpretation report](visual-grammar/iphone17-ink-interpretation.json). The complete fictional interpretation finished in about 8.3 seconds, including DReAMy and both Foundation Models requests. DReAMy was available; title, reading, open question and valid three-path recipe were returned. No diary entry was created by the probe. The app was then launched normally without verification arguments.

After the final asymmetrical gesture revision, the targeted 11-method grammar suite (including 14 family cases and old-renderer golden compatibility) also passed.

The final refinement UI check also passed after that revision: preview, cancel, confirm, restart and reopen, with the saved portrait and explanation captured in a simulator screenshot.
