import FoundationModels

@Generable
struct NarrativeModelCue {
  @Guide(
    description:
      "One literal visual cue kind: branching, doors, crowd, connection, rising, falling, drifting, rescue, bending, fracture, repetition, light, emptiness, blurred, rotation, simultaneous, sceneChange, directions. No symbol meanings."
  )
  var kind: String
  @Guide(
    description:
      "An exact short quotation from the supplied dream report supporting this cue. Do not invent or paraphrase the quotation. Up to 160 characters."
  )
  var excerpt: String
  @Guide(
    description:
      "Explicit count only, between 1 and 8. Use 1 if the quantity is unknown. Never infer unmentioned characters."
  )
  var count: Int
}
