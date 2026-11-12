# DREAM - indice di tutti i sorgenti Swift

Percorsi relativi a `Sources/`. Ogni riga indica la responsabilita del file. Per il percorso completo di esecuzione leggere [CODE_MAP.md](CODE_MAP.md).

## App

| File | Responsabilita |
| --- | --- |
| [DreamApp.swift](../Sources/App/DreamApp.swift) | Avvio, store condiviso e stile generale. |

## Artwork/Analysis

| File | Responsabilita |
| --- | --- |
| [NarrativeCue.swift](../Sources/Artwork/Analysis/NarrativeCue.swift) | Indizio con tipo, citazione, conteggio e origine. |
| [NarrativeCueKind.swift](../Sources/Artwork/Analysis/NarrativeCueKind.swift) | Vocabolario chiuso degli indizi accettati. |
| [NarrativeModelAnalyzer.swift](../Sources/Artwork/Analysis/NarrativeModelAnalyzer.swift) | Adattatore opzionale Foundation Models per gli indizi. |
| [NarrativeModelCue.swift](../Sources/Artwork/Analysis/NarrativeModelCue.swift) | Formato generabile di un indizio suggerito. |
| [NarrativeModelReading.swift](../Sources/Artwork/Analysis/NarrativeModelReading.swift) | Contenitore della risposta strutturata per gli indizi. |
| [NarrativeVisualAnalyzer.swift](../Sources/Artwork/Analysis/NarrativeVisualAnalyzer.swift) | Regole letterali inglesi e controllo delle citazioni. |
| [NarrativeVisualFeatures.swift](../Sources/Artwork/Analysis/NarrativeVisualFeatures.swift) | Indizi e impronta del testo analizzato. |

## Artwork/Composition

| File | Responsabilita |
| --- | --- |
| [VisualRuleEngine+Refinement.swift](../Sources/Artwork/Composition/VisualRuleEngine+Refinement.swift) | Variazioni di seed, intensita e palette richieste dall’utente. |
| [VisualRuleEngine.swift](../Sources/Artwork/Composition/VisualRuleEngine.swift) | Scelta della composizione e registrazione delle ragioni. |

## Artwork/Geometry

| File | Responsabilita |
| --- | --- |
| [FamilyGeometry.swift](../Sources/Artwork/Geometry/FamilyGeometry.swift) | Coordinate, trasformazioni, primitive e selezione della famiglia. |

## Artwork/Geometry/Families

| File | Responsabilita |
| --- | --- |
| [FamilyGeometry+AngularRays.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+AngularRays.swift) | Settori radiali di ampiezza variabile. |
| [FamilyGeometry+BranchingPaths.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+BranchingPaths.swift) | Ramificazione ricorsiva della resa di base. |
| [FamilyGeometry+ChromaticHaze.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+ChromaticHaze.swift) | Campi morbidi e nastri di colore. |
| [FamilyGeometry+ConstellationGraph.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+ConstellationGraph.swift) | Rete con rilassamento a molle e repulsione. |
| [FamilyGeometry+FlowField.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+FlowField.swift) | Linee integrate in un campo di flusso rumoroso. |
| [FamilyGeometry+FracturedCells.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+FracturedCells.swift) | Celle di Voronoi ritagliate e separate. |
| [FamilyGeometry+InterferenceWaves.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+InterferenceWaves.swift) | Contorni di due onde, estratti con marching squares. |
| [FamilyGeometry+LayeredCollage.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+LayeredCollage.swift) | Piani di carta sovrapposti. |
| [FamilyGeometry+NegativeVoid.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+NegativeVoid.swift) | Spazio vuoto e fuoco luminoso solo se menzionato. |
| [FamilyGeometry+NestedEchoes.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+NestedEchoes.swift) | Contorni annidati della resa di base. |
| [FamilyGeometry+ParticleField.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+ParticleField.swift) | Punti distanziati e raggruppati. |
| [FamilyGeometry+SpiralImprint.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+SpiralImprint.swift) | Nastro a spirale irregolare. |
| [FamilyGeometry+ThresholdRooms.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+ThresholdRooms.swift) | Cornici prospettiche della resa di base. |
| [FamilyGeometry+WarpedBands.swift](../Sources/Artwork/Geometry/Families/FamilyGeometry+WarpedBands.swift) | Bande parallele deformate. |

## Artwork/Geometry/Ink

| File | Responsabilita |
| --- | --- |
| [HandDrawnGeometry+ConstellationGraph.swift](../Sources/Artwork/Geometry/Ink/HandDrawnGeometry+ConstellationGraph.swift) | Nuclei organici contornati e collegamenti curvi. |
| [HandDrawnGeometry+NestedEchoes.swift](../Sources/Artwork/Geometry/Ink/HandDrawnGeometry+NestedEchoes.swift) | Contorni ripetuti e progressivamente spostati. |
| [HandDrawnGeometry+ThresholdRooms.swift](../Sources/Artwork/Geometry/Ink/HandDrawnGeometry+ThresholdRooms.swift) | Portali aperti e superfici prospettiche a penna. |
| [HandDrawnGeometry.swift](../Sources/Artwork/Geometry/Ink/HandDrawnGeometry.swift) | Gesti ramificati costruiti con curve di Bezier. |
| [HandDrawnRenderer+Hatching.swift](../Sources/Artwork/Geometry/Ink/HandDrawnRenderer+Hatching.swift) | Tratteggio limitato all’interno dei poligoni. |
| [HandDrawnRenderer.swift](../Sources/Artwork/Geometry/Ink/HandDrawnRenderer.swift) | Pressione, ripassi, contorni e velature sui segni. |

## Artwork/Models

| File | Responsabilita |
| --- | --- |
| [DreamVisualRecipe.swift](../Sources/Artwork/Models/DreamVisualRecipe.swift) | Ricetta salvata, identita, validazione e sintesi della spiegazione. |
| [FinishRecipe.swift](../Sources/Artwork/Models/FinishRecipe.swift) | Grana, irregolarita del bordo e diffusione dell’inchiostro. |
| [MotionRecipe.swift](../Sources/Artwork/Models/MotionRecipe.swift) | Campi riservati: le nuove stampe sono statiche. |
| [NormalizedPoint.swift](../Sources/Artwork/Models/NormalizedPoint.swift) | Posizione normalizzata con limiti. |
| [PaletteRecipe.swift](../Sources/Artwork/Models/PaletteRecipe.swift) | Valori effettivi di carta e inchiostri. |
| [UserVisualAdjustments.swift](../Sources/Artwork/Models/UserVisualAdjustments.swift) | Scelte esplicite di intensita e palette. |
| [VisualDecision.swift](../Sources/Artwork/Models/VisualDecision.swift) | Motivazione tracciata di una scelta visiva. |
| [VisualDirection.swift](../Sources/Artwork/Models/VisualDirection.swift) | Direzione del movimento rappresentato. |
| [VisualEvidenceSource.swift](../Sources/Artwork/Models/VisualEvidenceSource.swift) | Distingue racconto, modello, DReAMy, arte e scelta personale. |
| [VisualFamily.swift](../Sources/Artwork/Models/VisualFamily.swift) | Le quattordici famiglie disponibili. |
| [VisualLayer.swift](../Sources/Artwork/Models/VisualLayer.swift) | Parametri geometrici di un singolo livello. |
| [VisualLayerRole.swift](../Sources/Artwork/Models/VisualLayerRole.swift) | Distingue struttura principale e livelli di supporto. |
| [VisualLayout.swift](../Sources/Artwork/Models/VisualLayout.swift) | Tipi di composizione registrati nella ricetta. |
| [VisualPalette.swift](../Sources/Artwork/Models/VisualPalette.swift) | Nomi delle palette selezionabili. |
| [VisualRGBA.swift](../Sources/Artwork/Models/VisualRGBA.swift) | Colore sRGB esplicito, opacita e luminanza. |

## Artwork/Random

| File | Responsabilita |
| --- | --- |
| [SeededNoise.swift](../Sources/Artwork/Random/SeededNoise.swift) | Rumore coerente interpolato e fBm a tre ottave. |
| [SeededRandom.swift](../Sources/Artwork/Random/SeededRandom.swift) | Sequenza SplitMix64 riproducibile da un seed. |

## Artwork/Rendering

| File | Responsabilita |
| --- | --- |
| [ProceduralRasterizer.swift](../Sources/Artwork/Rendering/ProceduralRasterizer.swift) | Conversione Core Graphics dei segni in pixel e PNG. |
| [ProceduralRenderEngine.swift](../Sources/Artwork/Rendering/ProceduralRenderEngine.swift) | Versione del renderer, livelli e finitura di base. |
| [RenderMark.swift](../Sources/Artwork/Rendering/RenderMark.swift) | Un segno geometrico con stile e dimensioni. |
| [RenderMarkKind.swift](../Sources/Artwork/Rendering/RenderMarkKind.swift) | Linea, poligono, ellisse o alone. |
| [RenderPlan.swift](../Sources/Artwork/Rendering/RenderPlan.swift) | Lista dei segni, limiti e impronta del piano. |
| [RenderPoint.swift](../Sources/Artwork/Rendering/RenderPoint.swift) | Coordinata quantizzata del piano di disegno. |

## Debug

| File | Responsabilita |
| --- | --- |
| [InterpretationProbe.swift](../Sources/Debug/InterpretationProbe.swift) | Verifica sintetica dei modelli, attiva solo con argomenti DEBUG. |
| [VisualGrammarProbe.swift](../Sources/Debug/VisualGrammarProbe.swift) | Verifica sintetica di immagini e pipeline sul dispositivo. |

## Features/Capture/Models

| File | Responsabilita |
| --- | --- |
| [DreamCaptureMode.swift](../Sources/Features/Capture/Models/DreamCaptureMode.swift) | Distingue registrazione e scrittura. |
| [DreamTranscript.swift](../Sources/Features/Capture/Models/DreamTranscript.swift) | Unisce i risultati parziali e finali della trascrizione. |
| [SpeechCaptureState.swift](../Sources/Features/Capture/Models/SpeechCaptureState.swift) | Stato audio protetto dal lock. |

## Features/Capture/Services

| File | Responsabilita |
| --- | --- |
| [DreamVoice.swift](../Sources/Features/Capture/Services/DreamVoice.swift) | Coordina permessi, registrazione, trascrizione e file audio. |
| [SpeechCaptureProcessor.swift](../Sources/Features/Capture/Services/SpeechCaptureProcessor.swift) | Scrive il PCM, converte il buffer e alimenta Speech. |
| [SpeechModelProvider.swift](../Sources/Features/Capture/Services/SpeechModelProvider.swift) | Prepara il modello inglese Speech sul dispositivo. |

## Features/Capture/Views

| File | Responsabilita |
| --- | --- |
| [DreamCaptureActions.swift](../Sources/Features/Capture/Views/DreamCaptureActions.swift) | Pulsanti Record/Write, adattati anche al testo grande. |
| [DreamCaptureEditor.swift](../Sources/Features/Capture/Views/DreamCaptureEditor.swift) | Campo di testo e controlli vocali nella Home. |
| [InterpretDreamButton.swift](../Sources/Features/Capture/Views/InterpretDreamButton.swift) | Pulsante di interpretazione con stato di attesa. |
| [VoiceControl.swift](../Sources/Features/Capture/Views/VoiceControl.swift) | Stato del microfono, timer e azione inizio/fine. |

## Features/Home

| File | Responsabilita |
| --- | --- |
| [DreamHome.swift](../Sources/Features/Home/DreamHome.swift) | Stato della cattura e navigazione principale. |
| [HomeDreamPreview.swift](../Sources/Features/Home/HomeDreamPreview.swift) | Titolo e immagine iniziale della Home. |

## Features/Interpretation

| File | Responsabilita |
| --- | --- |
| [DreamComposer.swift](../Sources/Features/Interpretation/DreamComposer.swift) | Coordina bozze, contesto notturno, lettura e ricetta visiva. |
| [DreamReading.swift](../Sources/Features/Interpretation/DreamReading.swift) | Formato strutturato della risposta scritta del modello. |
| [DreamReflectionSection.swift](../Sources/Features/Interpretation/DreamReflectionSection.swift) | Presenta lettura, domanda e stato della generazione. |
| [DreamTone.swift](../Sources/Features/Interpretation/DreamTone.swift) | Toni proposti dal modello per compatibilita del formato. |

## Features/Journal/Models

| File | Responsabilita |
| --- | --- |
| [DreamEntry.swift](../Sources/Features/Journal/Models/DreamEntry.swift) | Modello persistito del sogno e riferimenti a immagine/audio. |
| [DreamEntryDecoding.swift](../Sources/Features/Journal/Models/DreamEntryDecoding.swift) | Lettura retrocompatibile e conservazione dei vecchi disegni. |
| [DreamFeeling.swift](../Sources/Features/Journal/Models/DreamFeeling.swift) | Sensazioni disponibili e palette della resa storica. |
| [DreamMotif.swift](../Sources/Features/Journal/Models/DreamMotif.swift) | Tre motivi della resa storica, preservati per compatibilita. |

## Features/Journal/Views

| File | Responsabilita |
| --- | --- |
| [DreamDetail.swift](../Sources/Features/Journal/Views/DreamDetail.swift) | Compone dettaglio, modifica, contesto e condivisione. |
| [DreamEditView.swift](../Sources/Features/Journal/Views/DreamEditView.swift) | Modifica il racconto e la riflessione senza ridisegnare automaticamente. |
| [DreamJournal.swift](../Sources/Features/Journal/Views/DreamJournal.swift) | Navigazione delle pagine del diario. |
| [DreamRow.swift](../Sources/Features/Journal/Views/DreamRow.swift) | Anteprima di un sogno nel diario. |
| [NotebookEmpty.swift](../Sources/Features/Journal/Views/NotebookEmpty.swift) | Prima pagina quando il diario e vuoto. |
| [NotebookPage.swift](../Sources/Features/Journal/Views/NotebookPage.swift) | Pagina cartacea con data, racconto e immagine. |
| [NotebookPaper.swift](../Sources/Features/Journal/Views/NotebookPaper.swift) | Carta e righe del diario. |

## Features/Playback

| File | Responsabilita |
| --- | --- |
| [DreamAudioPlayback.swift](../Sources/Features/Playback/DreamAudioPlayback.swift) | Controllo SwiftUI per ascoltare la registrazione. |
| [DreamAudioPlayer.swift](../Sources/Features/Playback/DreamAudioPlayer.swift) | Riproduzione e rilascio della sessione audio. |

## Features/Portraits/Legacy

| File | Responsabilita |
| --- | --- |
| [DreamArtwork.swift](../Sources/Features/Portraits/Legacy/DreamArtwork.swift) | Contenitore temporale della vecchia resa Canvas. |
| [DreamCanvas.swift](../Sources/Features/Portraits/Legacy/DreamCanvas.swift) | Algoritmo storico conservato per i vecchi sogni. |
| [LegacyPortrait.swift](../Sources/Features/Portraits/Legacy/LegacyPortrait.swift) | Parametri congelati della vecchia immagine. |

## Features/Portraits/Services

| File | Responsabilita |
| --- | --- |
| [PortraitImageLoader.swift](../Sources/Features/Portraits/Services/PortraitImageLoader.swift) | Carica e ridimensiona immagini fuori dal main actor. |
| [PortraitService.swift](../Sources/Features/Portraits/Services/PortraitService.swift) | Generazione/cache PNG e riuso dello snapshot archiviato. |

## Features/Portraits/Views

| File | Responsabilita |
| --- | --- |
| [DreamPortrait.swift](../Sources/Features/Portraits/Views/DreamPortrait.swift) | Sceglie la resa salvata o quella storica. |
| [DreamPortraitPlaceholder.swift](../Sources/Features/Portraits/Views/DreamPortraitPlaceholder.swift) | Immagine iniziale quando non ci sono sogni. |
| [PortraitExplanation.swift](../Sources/Features/Portraits/Views/PortraitExplanation.swift) | Spiegazione delle scelte e avviso sul racconto modificato. |
| [PortraitRefinementView.swift](../Sources/Features/Portraits/Views/PortraitRefinementView.swift) | Anteprima delle variazioni, annullamento e conferma. |
| [RecipeArtwork.swift](../Sources/Features/Portraits/Views/RecipeArtwork.swift) | Carica e presenta il PNG con descrizione accessibile. |

## Integrations/Dreamy

| File | Responsabilita |
| --- | --- |
| [DreamBERTTokenizer.swift](../Sources/Integrations/Dreamy/DreamBERTTokenizer.swift) | Tokenizzazione WordPiece per il checkpoint BERT. |
| [DreamBERTTokens.swift](../Sources/Integrations/Dreamy/DreamBERTTokens.swift) | Vettori di input del classificatore. |
| [DreamEmotion.swift](../Sources/Integrations/Dreamy/DreamEmotion.swift) | Le cinque etichette indipendenti DReAMy. |
| [DreamEmotionAnalysis.swift](../Sources/Integrations/Dreamy/DreamEmotionAnalysis.swift) | Risultato del classificatore e compatibilita storica. |
| [DreamEmotionAnalyzer.swift](../Sources/Integrations/Dreamy/DreamEmotionAnalyzer.swift) | Inferenza BERT Core ML sul dispositivo. |
| [DreamEmotionView.swift](../Sources/Integrations/Dreamy/DreamEmotionView.swift) | Presenta i suggerimenti emotivi come ipotesi. |

## Integrations/Health

| File | Responsabilita |
| --- | --- |
| [DreamNightSection.swift](../Sources/Integrations/Health/DreamNightSection.swift) | Caricamento facoltativo e presentazione del contesto notturno. |
| [HealthService.swift](../Sources/Integrations/Health/HealthService.swift) | Legge sonno e frequenza cardiaca autorizzati da HealthKit. |
| [NightContext.swift](../Sources/Integrations/Health/NightContext.swift) | Contesto notturno associato al sogno. |
| [NightSummary.swift](../Sources/Integrations/Health/NightSummary.swift) | Riepilogo SwiftUI dei dati disponibili. |
| [SleepInterval.swift](../Sources/Integrations/Health/SleepInterval.swift) | Intervallo di sonno e fase. |
| [SleepStage.swift](../Sources/Integrations/Health/SleepStage.swift) | Fasi del sonno normalizzate. |
| [SleepTimeline.swift](../Sources/Integrations/Health/SleepTimeline.swift) | Costruzione e verifica della sequenza di fasi. |
| [SleepTimelineView.swift](../Sources/Integrations/Health/SleepTimelineView.swift) | Visualizzazione della sequenza del sonno. |

## Integrations/SLAMSS

| File | Responsabilita |
| --- | --- |
| [SLAMSSImportError.swift](../Sources/Integrations/SLAMSS/SLAMSSImportError.swift) | Errori leggibili dei report di ricerca. |
| [SLAMSSProvenance.swift](../Sources/Integrations/SLAMSS/SLAMSSProvenance.swift) | Origine, pesi e provenienza delle stime importate. |
| [SLAMSSReport.swift](../Sources/Integrations/SLAMSS/SLAMSSReport.swift) | Decodifica e valida il formato del report esterno. |
| [SLAMSSResearchSection.swift](../Sources/Integrations/SLAMSS/SLAMSSResearchSection.swift) | Importazione e presentazione delle stime di ricerca. |

## Persistence

| File | Responsabilita |
| --- | --- |
| [DreamDraft.swift](../Sources/Persistence/DreamDraft.swift) | Formato della bozza. |
| [DreamDraftStore.swift](../Sources/Persistence/DreamDraftStore.swift) | Recupero e salvataggio della bozza. |
| [DreamStore.swift](../Sources/Persistence/DreamStore.swift) | Salvataggio protetto di diario e PNG; cancellazione dei file del sogno. |

## Shared/Views

| File | Responsabilita |
| --- | --- |
| [DreamcatcherMark.swift](../Sources/Shared/Views/DreamcatcherMark.swift) | Segno grafico condiviso. |

## Artwork/Geometry/Etching - renderer 3

| File | Responsabilita |
| --- | --- |
| [EtchingGeometry+Architecture.swift](../Sources/Artwork/Geometry/Etching/EtchingGeometry+Architecture.swift) | Portali, raggi, frammenti Voronoi e collage. |
| [EtchingGeometry+Atmospheres.swift](../Sources/Artwork/Geometry/Etching/EtchingGeometry+Atmospheres.swift) | Particelle, spazio negativo e immagini indefinite. |
| [EtchingGeometry+Fields.swift](../Sources/Artwork/Geometry/Etching/EtchingGeometry+Fields.swift) | Correnti direzionali, bande e interferenze. |
| [EtchingGeometry+Gestures.swift](../Sources/Artwork/Geometry/Etching/EtchingGeometry+Gestures.swift) | Ramificazioni, connessioni, contorni ripetuti e spirali. |
| [EtchingGeometry+Knots.swift](../Sources/Artwork/Geometry/Etching/EtchingGeometry+Knots.swift) | Intrecci toroidali e campi di inchiostro generati da attrattori. |
| [EtchingGeometry.swift](../Sources/Artwork/Geometry/Etching/EtchingGeometry.swift) | Selezione degli studi, coordinate, volumi e nastri di Bezier. |

`Artwork/Models/PaletteRecipe+Etching.swift`: carte e inchiostri delle nuove stampe.
