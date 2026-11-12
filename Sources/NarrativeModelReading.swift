import FoundationModels

@Generable
struct NarrativeModelReading {
  @Guide(
    description:
      "At most eight literal visual cues supported by exact excerpts. Return an empty list if none is clear."
  )
  var cues: [NarrativeModelCue]
}
