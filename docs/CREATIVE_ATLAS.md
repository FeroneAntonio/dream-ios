# DREAM - expressive etchings and the 432-study atlas

Version 0.6 / build 11 introduces renderer 3. The 14 family names remain semantic categories; the geometry inside them now has substantial seeded variation. All artwork is procedural Swift/Core Graphics. No AI image generator, Pinterest image or pre-rendered material texture is used.

## What changed

- **Gesture:** ribbons vary junctions, curvature, cross-section and spread. Branching also has a recursive tree study. Original narrative branch counts remain in the recipe.
- **Space:** open rectangular and curved thresholds vary their vanishing point, slant, depth and shadow planes. Collage uses irregular cut planes instead of fixed strips.
- **Organic form:** contours vary their lobes, shape, center drift, aspect and opening; repetition can become displaced sections or overlapping contour groups. Paper knockouts and concentrated black cores separate foreground volumes from connecting ribbons.
- **Interweaving:** projected toroidal paths introduce closed woven folds for rotation and overlapping rhythms. Parameters change the actual path, not merely its color or rotation.
- **Ink deposition:** bounded Clifford maps deposit thousands of procedural points for selected atmospheric/multitude studies. Layer count and role limit their budget so three dense layers remain within the existing print limits.
- **Movement:** directional currents preserve rising/falling/crossing and convergence, but vary their width, meander, spacing and pressure.
- **Fragments:** real Voronoi cells now form irregular cut masses with gaps and displaced edges rather than a rectangular tile.
- **Materials:** five restricted paper/ink stocks for new Ink / Paper compositions; palette values are stored. Explicit user palette choices still take precedence. Dark-paper inks are lifted for visibility.
- **Narrative:** a broader literal English vocabulary and up to two supported secondary structures make more of the report visible. Every narrative addition retains an exact supporting quotation. Palette and seeded gesture choices remain artistic decisions.

## Reproduce the atlas

```sh
python3 scripts/render_visual_gallery.py --atlas --output /private/tmp/DREAM-Creative-Atlas-432
```

The tool compiles the production `Sources/Artwork/` code and the emotion-label enum, excluding the optional Foundation Models adapter. It does not load DReAMy, Health, microphone or personal diary data.

- **320 narrative studies:** 40 different fictional reports, eight fixed seeds per report.
- **112 technical studies:** 14 families, eight fixed seeds each. These are labeled as technical studies, not dream interpretations.
- The seed-selection routine deliberately covers six geometric study modes in each comparison row, so a random batch cannot accidentally hide an entire mode. Additional dimensions remain continuous and seeded.
- Every study exports its PNG, frozen recipe and a manifest record with seed, family, explanation, plan hash and mark/point counts.
- The local HTML gallery supports family/series filters and text search. Contact sheets are supplementary exports, not app image assets.

432 is the size of this comparison, not a claim of 432 separate algorithms or a finite library of preset images. A distinct geometry hash verifies difference, not artistic quality; visual comparison remains necessary. The atlas is an engineering/creative fixture set, not psychological ground truth.

## Preservation

Previously saved renderer-1 and renderer-2 recipes keep their original engines and snapshots. Golden fixtures verify their original plan hashes. New captures use renderer 3. For a saved dream, **Refine portrait** previews an upgrade; only **Use portrait** changes it. Editing the story still does not silently replace its image.

## Code map

`Artwork/Geometry/Etching/EtchingGeometry.swift` dispatches the family and provides volume/ribbon primitives. Extensions split gestures, architecture, fields, atmospheres and knots into readable files. `PaletteRecipe+Etching.swift` defines the stocks. Existing version-2 geometry is retained under `Geometry/Ink/`; shared pressure/hatching and rasterization remain shared, with version-gated paper handling.

## Verification scope

The test suite includes repeatability across all 14 families and six seeds, actual raw-geometry diversity before grain, quotation-supported secondary layers, unchanged renderer-1/2 golden fixtures, refinement invariants, and three maximum-density layers across all families. Full test/device results are recorded in `VISUAL_GRAMMAR_VALIDATION.md` after execution. A static print remains static; no animation feature was added.

## Observed results

43 Swift test methods and five UI tests passed (separate runs). All 432 atlas images/plans are distinct and bounded; this is a diversity check, not an aesthetic score. iPhone 17 completed forty 1080 px prints: 25.1-89.6 ms, median 46.7 ms, in one Debug pass. [Overview](creative-atlas/overview-40.png) · [Eight studies of the same story](creative-atlas/same-story-eight-studies.png) · [Raw verification](creative-atlas/verification.json).
