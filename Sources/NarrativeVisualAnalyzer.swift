import Foundation

struct NarrativeVisualAnalyzer {
  static func normalized(_ text: String) -> String {
    text.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased()
  }
  static func verifiedExcerpt(_ quote: String, in text: String) -> Bool {
    let excerpt = normalized(quote)
    return !excerpt.isEmpty && quote.count <= 240 && normalized(text).contains(excerpt)
  }

  // Conservative literal English patterns: a fallback, not a symbol dictionary.
  static func local(_ text: String) -> NarrativeVisualFeatures {
    let patterns: [(NarrativeCueKind, String)] = [
      (
        .branching,
        #"\b(?:paths?|roads?) (?:split|divided|branched)(?: into (?:two|three|four|five|[2-5]))?\b"#
      ),
      (
        .doors,
        #"\b(?:(?:one|two|three|four|five|six|seven|eight|[1-8]) )?(?:doors?|rooms?|corridor)\b"#
      ),
      (.crowd, #"\b(?:crowd|crowded|hundreds|rain|many small)\b"#),
      (
        .connection,
        #"\b(?:my mother|my father|my friend|my sister|my brother|with friends|someone reached out)\b"#
      ),
      (.rising, #"\b(?:rose to the surface|rising|climbed|climbing|flew upward)\b"#),
      (.drifting, #"\b(?:walking|swimming|drifting|floating)\b"#),
      (.falling, #"\b(?:falling|fell|sinking|being dragged)\b"#),
      (.rescue, #"\b(?:caught me|rescued me|felt safe|held my hand)\b"#),
      (.bending, #"\b(?:bent sideways|kept bending|bending|parallel|warped|wavy)\b"#),
      (.fracture, #"\b(?:broke into small pieces|shattered|broke apart|fragmented)\b"#),
      (
        .repetition,
        #"\b(?:back to the same quiet room|back to the same|over and over|kept returning|again and again|endless|never ended)\b"#
      ),
      (.light, #"\b(?:distant light|sunlight|light|glow)\b"#),
      (
        .emptiness,
        #"\b(?:empty(?:, quiet)? space|nothing else was there|nothing was there|completely alone)\b"#
      ),
      (.blurred, #"\b(?:blurry|blurred|hazy|vague|indistinct)\b"#),
      (.rotation, #"\b(?:spinning|rotating|in circles|turning around)\b"#),
      (.simultaneous, #"\b(?:two voices|at once|simultaneously)\b"#),
      (.sceneChange, #"\b(?:then|suddenly|changed into|another place)\b"#),
      (.directions, #"\b(?:many directions|rays|converging|diverging)\b"#),
    ]
    var cues: [NarrativeCue] = []
    for (kind, pattern) in patterns {
      guard let expression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
        let match = expression.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
        let range = Range(match.range, in: text)
      else { continue }
      let excerpt = String(text[range])
      let prefix = String(text[..<range.lowerBound].suffix(32))
      if prefix.range(
        of: #"\b(?:no|without|not)\s+(?:(?:any|a|the|really|actually|one)\s+)?$"#,
        options: [.regularExpression, .caseInsensitive]) != nil
      {
        continue
      }
      let numbers = [
        "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8,
      ]
      let words = normalized(excerpt).split(separator: " ").map(String.init)
      let count = words.compactMap { numbers[$0] ?? Int($0) }.first ?? (kind == .connection ? 2 : 1)
      cues.append(NarrativeCue(kind: kind, excerpt: excerpt, count: count))
    }
    return NarrativeVisualFeatures(
      inputFingerprint: DreamVisualRecipe.fingerprint(text), cues: cues)
  }

  static func merging(
    _ suggestions: [NarrativeCue], into local: NarrativeVisualFeatures, text: String
  ) -> NarrativeVisualFeatures {
    var result = local
    for suggestion in suggestions.prefix(8) {
      // Unsupported/imagined quotes never acquire narrative authority.
      guard verifiedExcerpt(suggestion.excerpt, in: text), (1...8).contains(suggestion.count),
        !result.has(suggestion.kind)
      else { continue }
      var cue = suggestion
      cue.source = .modelSuggestion
      result.cues.append(cue)
    }
    result.usedLanguageModel = true
    result.analyzedBeginningOnly = text.count > 5000
    return result
  }
}
