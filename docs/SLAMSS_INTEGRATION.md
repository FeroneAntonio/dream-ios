# SLAMSS-IFS in DREAM

SLAMSS-IFS estimates sleep stages from heart rate and wrist-motion features. It does not interpret a dream report, identify nightmares, or tell us when a remembered dream occurred. DREAM therefore keeps its output separate from the text interpretation and from Apple Health estimates.

## What is implemented

- Original architecture vendored byte-for-byte from [BIDSLabUMass/SLAMSS-IFS](https://github.com/BIDSLabUMass/SLAMSS-IFS), commit `088e363873b4ac5b27bc23fb038abc052889698c`, under BSD-3-Clause. Source SHA-256: `528582591d9b4b31ae56a109394dce3d927d07ed77a7edb2e2087a280423561e`.
- CPU research inference using genuine separately supplied CNN/sequence checkpoints, strict state-dict loading, SHA-256 checks and `torch.load(weights_only=True)`.
- Explicit preparation contract for the upstream **prepared MAT features**. We do not invent a raw-data preprocessing pipeline.
- Versioned `.dreamnight.json` output with source, checkpoint hashes, starting-stage assumption and research status.
- iPhone import with bounded file size, date/shape/provenance/score validation and rejection of declared synthetic results.
- A separate research timeline under **Sleep research** in a dream detail. Imported estimates survive journal reopening.
- Native Apple Health stages retained and displayed under **The night**. Overlaps are normalized without double counting; gaps and conflicting detailed labels remain unclassified.

An imported JSON file is an external research report, not an authenticated or independently validated scientific result. Hash strings provide traceability; the iPhone cannot prove the supplied weights were genuinely trained.

## Actual activation status

**No SLAMSS inference runs on the iPhone.** At inspection on 12 November 2026, upstream published architecture and notebooks but no trained checkpoints/releases. Its [model-weights issue](https://github.com/BIDSLabUMass/SLAMSS-IFS/issues/1) remained unanswered. Required feature derivations are also incomplete. The adapter is ready for genuine research assets; there are no fabricated model estimates.

Standard historical HealthKit heart-rate summaries and sleep stages are not substitutes for synchronized, sufficiently sampled heart and accelerometry signals. DREAM has no watchOS raw-motion recorder. We do not turn sparse sampled heart rate into the study's input by interpolation.

The [BIDSleep data release](https://physionet.org/content/bidsleep-dataset/1.0.0/) supplies raw study data; the complete dataset was not downloaded or republished. New training or validation would be a separate research task.

## Reproduction and corrections

The code actually uses GRUs, even though some upstream descriptions mention LSTMs. Preserve the architecture when loading its checkpoints.

Upstream prepared inputs:

- `hr`: one IHR sample per second; divide by 60 and z-normalize over the recording.
- `act`: synchronized per-second actigraphy; z-normalize over the recording.
- `hz`, `clock`, `time`: one value per 30-second epoch.
- `hr2`: shape `(2, epochs)`, divide by 60.
- Feature order: `[hz, clock, time, hr2[0]/60, hr2[1]/60]`.
- Signal order: `[normalized_hr, normalized_act]`.
- Class order: awake, light (N1/N2), deep, REM.

The testing notebook slices the epoch features to three channels while `CNN.cnn_ACT` expects five. This adapter requires all five. Exact raw derivations of these prepared features must be obtained and validated before real recordings are processed.

Even with teacher forcing disabled, upstream initializes the decoder from `target[:, 0]`, the first ground-truth stage. An unlabeled runner must not read that label. Our runner accepts an explicit starting stage and a required explanation of its known or assumed basis, records both, and never loads the MAT ground-truth field. This affects reproducibility and prevents claiming the paper's accuracy for this adapter.

The variable-length recording is evaluated as supplied, up to 1,200 epochs. The notebook pads shorter recordings to 1,200 epochs. Because bidirectional/attention context can change, this adapter is **not** an exact replication of published evaluation. Predictions and uncertainty need separate validation.

## Running research inference

```sh
cd Research/SLAMSSIFS
python3.12 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/python -m unittest discover -s tests -v
```

Create a private manifest from `checkpoints.example.json`. The example deliberately fails validation. Supply actual trained checkpoint paths, hashes, source and training provenance; declare `trained: true`, `synthetic: false` only when true.

```sh
.venv/bin/python -m dream_slamss.infer \
  --features /private/path/authentic-prepared-night.mat \
  --manifest /private/path/checkpoints.json \
  --start 2026-11-12T00:00:00Z \
  --initial-stage awake \
  --initial-stage-basis 'Awake at recording start, confirmed in acquisition log' \
  --output /private/path/night.dreamnight.json
```

Use the actual acquisition start, not this example date. Import the result into the corresponding dream. Test random weights are used only to check tensor plumbing and are never exported as a night report.

## How it helps the future artwork

A validated sequence could add temporal rhythm, transitions and fragmentation as clearly identified sleep context. It cannot establish fear, dream meaning, emotional intensity or a particular dream's timing. Keep this separate from DReAMy's text-emotion suggestions and the dreamer's own feelings. Geometry mappings are artistic choices that must remain explainable and editable.
