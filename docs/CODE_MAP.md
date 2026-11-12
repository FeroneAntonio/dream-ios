# DREAM - mappa del codice

Questa guida spiega dove cercare e in quale ordine leggere il progetto. Le cartelle sono reali sul disco e rispecchiate nei gruppi di Xcode. L'app resta un solo target: non ci sono pacchetti o livelli di astrazione aggiunti per organizzare i file.

[Indice di tutti i 117 sorgenti Swift](SWIFT_FILE_INDEX.md): file e responsabilita.

## Le cartelle principali

```text
Sources/
  App/                    Avvio dell'app e dipendenze condivise
  Features/
    Home/                 Home e anteprima dell'ultimo sogno
    Capture/              Scrittura, microfono e trascrizione
      Models/             Modalita e stato della cattura
      Services/           Registrazione e pipeline Speech
      Views/              Controlli visivi e campo di testo
    Interpretation/       Coordinamento dei modelli e lettura scritta
    Journal/              Diario, dettaglio e modifica del sogno
      Models/             DreamEntry e lettura del formato salvato
      Views/              Schermate del diario
    Portraits/            Immagine, anteprima e rifinitura
      Services/           Cache PNG e caricamento immagini
      Views/              Presentazione SwiftUI e conferma modifiche
      Legacy/             Disegni storici, conservati per compatibilita
    Playback/             Ascolto degli audio salvati
  Artwork/
    Analysis/             Racconto -> indizi verificabili
    Composition/          Indizi -> ricetta e modifiche dell'utente
    Models/               Formato della ricetta, livelli, palette, motivazioni
    Geometry/
      FamilyGeometry.swift   Trasformazioni e selezione della famiglia
      Families/           Un algoritmo per ciascuna delle 14 famiglie
      Ink/                Geometrie a penna, pressione e tratteggio
    Random/               Casuale riproducibile e rumore coerente
    Rendering/            Segni normalizzati -> pixel -> PNG
  Integrations/
    Dreamy/               Classificatore Core ML e tokenizer BERT
    Health/               Contesto notturno e schermate dei dati
    SLAMSS/               Importazione delle stime di ricerca esterne
  Persistence/            JSON, bozze, immagini e gestione dei file
  Shared/Views/           Elementi visivi condivisi
  Debug/                  Verifiche sintetiche, inattive all'avvio normale
Tests/                    Test unitari divisi per funzionalita
UITests/                  Test della cattura e della rifinitura
Fixtures/                 Racconti fittizi e ricetta storica di riferimento
Tools/VisualGallery.swift Genera la galleria usando il renderer dell'app
scripts/                  Aggiornamento progetto, modello e galleria
```

## Il percorso di un sogno

1. `Features/Home/DreamHome.swift` possiede lo stato di cattura e avvia le azioni. Le viste figlie ricevono valori, binding e azioni; non salvano copie parallele del sogno.
2. `Features/Interpretation/DreamComposer.swift` coordina la lettura scritta, DReAMy e gli indizi narrativi. L'IA non disegna l'immagine.
3. `Artwork/Analysis/NarrativeVisualAnalyzer.swift` trova indizi letterali inglesi. `NarrativeModelAnalyzer.swift` aggiunge suggerimenti opzionali, con citazioni controllate.
4. `Artwork/Composition/VisualRuleEngine.swift` decide la struttura sulla base degli indizi. `VisualRuleEngine+Refinement.swift` applica le modifiche confermate dall'utente.
5. `Artwork/Models/DreamVisualRecipe.swift` congela seed, livelli, palette, finitura, versione e motivazioni.
6. `Artwork/Rendering/ProceduralRenderEngine.swift` seleziona la versione del renderer. Le ricette nuove usano la resa a inchiostro; quelle precedenti mantengono la propria.
7. `Artwork/Geometry/Families/` contiene gli algoritmi generali. `Artwork/Geometry/Ink/` contiene le varianti gestuali e la lavorazione dei segni.
8. `Artwork/Rendering/ProceduralRasterizer.swift` disegna i segni con Core Graphics e produce il PNG.
9. `Features/Portraits/Services/PortraitService.swift` gestisce cache e snapshot. `Persistence/DreamStore.swift` salva immagine e diario con protezioni contro scritture incomplete.
10. `Features/Portraits/Views/RecipeArtwork.swift` presenta l'immagine. `PortraitExplanation.swift` mostra il motivo delle scelte. Il dettaglio del diario li compone.

## Da dove iniziare per cambiare un disegno

| Voglio cambiare... | File da aprire |
| --- | --- |
| Quali parole vengono riconosciute | `Artwork/Analysis/NarrativeVisualAnalyzer.swift` |
| Quale geometria viene scelta | `Artwork/Composition/VisualRuleEngine.swift` |
| I tre sentieri a penna | `Artwork/Geometry/Ink/HandDrawnGeometry.swift` |
| Le porte impossibili | `Artwork/Geometry/Ink/HandDrawnGeometry+ThresholdRooms.swift` |
| Le forme collegate | `Artwork/Geometry/Ink/HandDrawnGeometry+ConstellationGraph.swift` |
| Le onde di movimento | `Artwork/Geometry/Families/FamilyGeometry+FlowField.swift` |
| Spessore, pressione e ripassi | `Artwork/Geometry/Ink/HandDrawnRenderer.swift` |
| Il tratteggio interno | `Artwork/Geometry/Ink/HandDrawnRenderer+Hatching.swift` |
| I colori disponibili | `Artwork/Models/PaletteRecipe.swift` |
| Il testo di Why this drawing | Motivazioni in `VisualRuleEngine.swift`, sintesi in `DreamVisualRecipe.swift` |
| Come si salva il disegno | `Persistence/DreamStore.swift` |

## Regole per mantenere il codice leggibile

- Un tipo per file; le estensioni dividono responsabilita concrete dello stesso algoritmo.
- Le viste descrivono la schermata. Le azioni sono metodi; gli algoritmi stanno fuori dalle viste.
- Nessuna lettura di Health, modelli o orologio dentro il generatore geometrico: riceve una ricetta.
- Ordine dei calcoli e generatore casuale conservati: spostare un metodo non deve cambiare i pixel.
- Formattazione uniforme: due spazi e righe di circa 100 caratteri, configurati in `.swift-format`.
- Aggiornare i gruppi con `python3 scripts/update_project.py` quando si aggiungono o spostano file. Lo script preserva target, firma e impostazioni, ed e idempotente.

## Comandi utili

```sh
# Formattazione e controllo
xcrun swift-format format --in-place --recursive Sources Tests UITests Tools
xcrun swift-format lint --strict --recursive Sources Tests UITests Tools

# Gruppi Xcode allineati alle cartelle
python3 scripts/update_project.py

# Galleria: richiede macOS e Xcode
python3 scripts/render_visual_gallery.py --output /private/tmp/DREAM-gallery
```

Il renderer della galleria usa gli stessi sorgenti dell'app, senza caricare l'interfaccia iOS o i modelli. I test dell'app si eseguono con lo scheme DREAM. I file di ricerca upstream in `Research/` mantengono struttura e licenze originali.
