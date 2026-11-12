# Attribution and distribution

DReAMy: a library for dream-report annotation, Lorenzo Bertolini and collaborators.

- Toolkit: https://github.com/lorenzoscottb/DReAMy
- Model: https://huggingface.co/DReAMy-lib/bert-base-cased-DreamBank-emotion-presence
- Model revision: `302196dad5648c1a28d70de3055373ef11975f04`
- Declared model license: Apache-2.0. See LICENSE and UPSTREAM_MODEL_CARD.md.
- Research citation supplied by the model card: L. Bertolini, A. Michalak and J. Weeds, DReAMy, Sleep Medicine 115 (2024), pp. 406–407. DOI: https://doi.org/10.1016/j.sleep.2023.11.1092.

DREAM converts the genuine checkpoint to Core ML FP16, adapts its attention mask to avoid FP16 overflow, implements compatible tokenization in Swift, and uses its tentative emotion-presence annotations for a procedural artwork and personal reflection. This is a downstream modification; authors do not endorse DREAM. The original weight file is not committed to Git history. The converted package is distributed with this attribution and license as a release asset.

The source checkpoint hash, measured conversion differences and exact revision are retained in conversion-validation.json. DReAMy's published metrics are not DREAM clinical or psychological validation.
