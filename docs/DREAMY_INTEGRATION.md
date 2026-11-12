# DReAMy emotion model in DREAM

DREAM integrates the actual English [DReAMy DreamBank BERT checkpoint](https://huggingface.co/DReAMy-lib/bert-base-cased-DreamBank-emotion-presence), rather than an API wrapper or a replacement prompt. Upstream toolkit: [lorenzoscottb/DReAMy](https://github.com/lorenzoscottb/DReAMy).

## Role in the experience

1. Record or type a dream in English.
2. **Interpret dream** runs DReAMy on-device to suggest emotions appearing in the report.
3. Apple Foundation Models uses these tentative suggestions alongside the original narrative to write the possible personal reading and open question.
4. Suggestions are saved with the dream and shown below its text. The image appears above the reading.
5. Visual Grammar 1.0 uses independent presence hints only for small print-finish adjustments. Literal narrative cues choose geometry; emotion labels never choose hue or the primary family. User refinements override those finish hints. The old confusion→fragment / sadness→flow / happiness→orbit mapping remains solely for historical display compatibility.

See [Visual Grammar 1.0](VISUAL_GRAMMAR.md) for source hierarchy, preserved historical portraits, narrative evidence and the static recipe renderer.

If DReAMy is unavailable, the normal reading can continue. If Apple Intelligence is unavailable, DReAMy can still annotate and influence the portrait; the written fallback remains honestly labeled as a reflection prompt. Changing the dream text clears old emotion annotations and the unchanged AI reading so the revised story can be interpreted again; an explicitly edited reflection is preserved.

## Model and exact inference contract

- Repository: `DReAMy-lib/bert-base-cased-DreamBank-emotion-presence`.
- Immutable revision: `302196dad5648c1a28d70de3055373ef11975f04`.
- Original Safetensors SHA-256: `d6ada0805add6533d620634cf1c3ab6fc98d27f9c3b7e03e4004f51dcddf7fe5`.
- 108,314,117 F32 parameters; original checkpoint 433,284,180 bytes.
- Apache-2.0, as declared in the pinned model card. Attribution, upstream license and model card are preserved under `Research/DReAMy/`.
- Core ML ML Program, FP16 weights, fixed input `(1,512)`, int32 input IDs/mask/type IDs, float32 output logits. Native Core ML runtime, no third-party iOS package.
- Cased BERT WordPiece tokenizer, vocabulary 28,996, preserve accents/case, CLS101/SEP102/PAD0/UNK100, right truncation to 510 content tokens and right padding to 512.
- Raw logit order **AN, AP, SD, CO, HA**: anger, apprehension, sadness, confusion, happiness.
- Independent **sigmoid**, not softmax. Each emotion is present only at score **strictly greater than 0.5**, matching the upstream library.
- More than one or no emotion can be suggested. Scores need not sum to one. They are model scores, not calibrated certainty about the person.
- English only: non-English detected reports skip this model; there is no silent translation. The full story remains saved. Long stories expose a truncation notice.

## Building with the genuine model

Generated model weights are distributed as a GitHub release asset rather than stored in Git history. Run `python3 scripts/fetch_dreamy_model.py` before opening/building the Xcode project. It downloads the pinned release asset, checks its SHA-256 and installs the model package/vocabulary. The app performs no HTTP requests and never uploads dream text.

For a fresh conversion on macOS:

```sh
python3.12 -m venv /tmp/dreamy-conversion
/tmp/dreamy-conversion/bin/pip install -r Research/DReAMy/requirements.txt
/tmp/dreamy-conversion/bin/python Research/DReAMy/convert.py \
  --cache /private/path/dreamy-checkpoint --output Models
python3 scripts/update_project.py
```

The standard float32 minimum attention mask is replaced with -10000 for the converted path to avoid FP16 overflow; the reference remains the unmodified PyTorch model.

Conversion downloads only this pinned checkpoint, checks its source SHA-256, uses eager attention and an evaluation-only traced logits wrapper, then compares original PyTorch and FP16 Core ML outputs on synthetic stories. Synthetic tokenization edge cases and numerical fixtures are retained for native Swift tests. See `conversion-validation.json` for measured conversion errors. These are engineering parity checks, not a psychological validation study.

## Limits and next candidates

Emotion annotation is useful structured context for a visual language. It does not decode hidden meanings, diagnose the dreamer or establish universal symbol meanings. Model card evaluation is not evidence of interpretation accuracy in DREAM; user corrections take precedence.

DReAMy's T5 character/activity extraction models could later guide separate geometric nuclei and relationships. They are **not integrated in this change**: each needs a separate conversion, validation and mobile performance check. XLM-R large is heavier and its Italian quality is unverified. Cortal's dream-t5 checkpoint has a noncommercial license, so it is not part of this app. SLAMSS-IFS is a separate sleep-stage research integration; see [its status](SLAMSS_INTEGRATION.md).


## Physical prototype check

The 0.4 integration also ran successfully on a physical iPhone 17 using a fixed fictional English report: DReAMy annotations were available, Apple Intelligence returned a reading, and a valid narrative-led recipe was produced. This is a functional engineering check, not classifier validation or standalone model latency/memory profiling. See [verification details](VISUAL_GRAMMAR_VALIDATION.md).
