import Foundation

extension DreamEntry {
  enum CodingKeys: String, CodingKey {
    case id, date, text, feeling, intensity, reflection, question, usedAI, night, motif, title,
      audioFilename, researchSleep, emotions
    case visualRecipe, legacyPortrait, portraitSnapshot
  }
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(UUID.self, forKey: .id)
    date = try values.decode(Date.self, forKey: .date)
    text = try values.decode(String.self, forKey: .text)
    feeling = try values.decodeIfPresent(DreamFeeling.self, forKey: .feeling) ?? .wonder
    intensity = try values.decodeIfPresent(Double.self, forKey: .intensity) ?? 0.5
    intensity = min(1, max(0, intensity))
    reflection = try values.decodeIfPresent(String.self, forKey: .reflection) ?? ""
    question = try values.decodeIfPresent(String.self, forKey: .question) ?? ""
    usedAI = try values.decodeIfPresent(Bool.self, forKey: .usedAI) ?? false
    night = try values.decodeIfPresent(NightContext.self, forKey: .night)
    motif = try values.decodeIfPresent(DreamMotif.self, forKey: .motif) ?? .orbit
    title = try values.decodeIfPresent(String.self, forKey: .title)
    audioFilename = try values.decodeIfPresent(String.self, forKey: .audioFilename)
    researchSleep = try values.decodeIfPresent(SLAMSSReport.self, forKey: .researchSleep)
    emotions = try values.decodeIfPresent(DreamEmotionAnalysis.self, forKey: .emotions)
    visualRecipe = try values.decodeIfPresent(DreamVisualRecipe.self, forKey: .visualRecipe)
    if let recipe = visualRecipe, !recipe.isValid {
      throw DecodingError.dataCorruptedError(
        forKey: .visualRecipe, in: values,
        debugDescription: "Invalid or unsupported visual recipe; original journal preserved")
    }
    legacyPortrait = try values.decodeIfPresent(LegacyPortrait.self, forKey: .legacyPortrait)
    if let legacyPortrait, !legacyPortrait.isValid {
      throw DecodingError.dataCorruptedError(
        forKey: .legacyPortrait, in: values,
        debugDescription: "Invalid legacy portrait; original journal preserved")
    }
    portraitSnapshot = try values.decodeIfPresent(String.self, forKey: .portraitSnapshot)
    // The text observer freezes legacy parameters immediately before an edit.
    // Reading a diary never rewrites or eagerly migrates its entries.
  }

  mutating func freezeLegacyPortraitIfNeeded() {
    guard visualRecipe == nil && legacyPortrait == nil else { return }
    legacyPortrait = LegacyPortrait(
      seed: seed, feeling: feeling, intensity: intensity, motif: motif)
  }
  var portraitUsesEarlierText: Bool {
    visualRecipe.map { $0.inputFingerprint != DreamVisualRecipe.fingerprint(text) } ?? false
  }
}
