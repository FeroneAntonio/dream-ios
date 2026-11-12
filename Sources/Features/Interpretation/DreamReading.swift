import FoundationModels

@Generable
struct DreamReading {
  @Guide(description: "A short, evocative English title, up to five words, specific to this dream.")
  var title: String
  @Guide(
    description:
      "An artistic motif: flow for motion or water, fragment for jumps and discontinuity, orbit for repeated paths. A visual metaphor, not a psychological fact."
  )
  var motif: DreamMotif
  @Guide(
    description:
      "A suggested visual tone grounded in the explicitly narrated experience, open to correction by the dreamer."
  )
  var tone: DreamTone
  @Guide(
    description:
      "Artistic visual energy between 0 and 1: quiet to turbulent. This is not a health or psychological score."
  )
  var visualEnergy: Double
  @Guide(
    description:
      "A thoughtful possible interpretation in English, two or three sentences. Connect specific narrative elements to a possible feeling or waking concern, using tentative language. No universal symbol meanings, predictions, diagnosis or hidden memories."
  )
  var observation: String
  @Guide(
    description:
      "One open English question about the dreamer's own personal associations, without suggesting past events."
  )
  var question: String
}
