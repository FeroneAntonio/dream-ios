# DREAM — ink, graphite and the dream image

The 0.5 art revision responds to Antonio's preference for minimal compositions with more expressive pencil/pen work. It adds rendering depth and gesture rather than more interface controls.

## Studied references

- **Odilon Redon** is the main reference for the dream image. His *Songes* portfolio consists of six lithographs ([MoMA](https://www.moma.org/collection/works/73107)). Getty's discussion of his *noirs* describes charcoal deposits, changes in pressure, deep shadows and luminous passages, as well as the openness of their interpretation ([Getty](https://www.getty.edu/news/black-is-the-most-essential-color-odilon-redons-noirs/)). The useful principles here are tonal concentration, breathing space and ambiguity—not a fixed dictionary of dream symbols.
- **André Masson**, *Automatic Drawing*, 1924: rapid, interconnected pen gestures and organic forms emerging from a web of lines ([MoMA](https://www.moma.org/collection/works/38201)). DREAM borrows the quality of the gesture; its composition still follows explicit narrative constraints rather than claiming unconscious automatism.
- **Fred Deux**: the Musée des Beaux-Arts de Lyon describes drawings often beginning with an ink stain, developed with other techniques, and identifies line and stain as fundamental elements ([2017 retrospective](https://www.mba-lyon.fr/fr/fiche-programmation/le-monde-de-fred-deux), [centenary display](https://www.mba-lyon.fr/fr/fiche-programmation/fred-deux-derniers-jours)). This informs the balance of etched detail, organic bodies and open paper. The Centre Pompidou also documents graphite and watercolor as the medium of *L'ancienne tradition* ([collection record](https://www.centrepompidou.fr/fr/ressources/oeuvre/cBKg6G8)).

These are curatorial research references and broad formal influences. No museum/Pinterest image, photograph, figure, signature or tracing is embedded in the renderer or app.

## Concrete code changes

`HandDrawnGeometry` and `HandDrawnScenery` give renderer 2 selected family-specific gestures:

- Branching becomes asymmetrical cubic ribbon bundles, with three large gestures when three paths are explicit. It replaces the diagram-like stem/twig rendering for new prints.
- Thresholds become offset open portals with hatched, impossible shadow planes.
- A meeting becomes organic, densely contoured focal bodies and a curved ink connection.
- Repetition uses displaced, uneven nested contours and changes in contour density.

`HandDrawnRenderer` adds coherent pressure along strokes, dry-nib irregularity, faint repeated pencil passes, clipped diagonal hatching and selected ink washes. It does not simply place photographic grain on the old picture. Other families retain their distinct underlying topology and receive the same material language. Ink/paper becomes the initial palette for most structural prints; colors remain adjustable and never encode a universal emotion meaning.

## Preservation and versioning

Grammar version remains 1; **renderer version 2** is explicit on newly created recipes. The missing renderer-version key in recipes saved by 0.4 means renderer 1. A golden fixture checks both the exact old recipe identity and its old render-plan digest. Archival snapshots also remain unchanged.

Opening an old dream never redraws it. Opening **Refine portrait** previews the new ink study, and only **Use portrait** replaces the saved work. Existing selected colors remain available. This lets the art improve without rewriting the person's diary history.
