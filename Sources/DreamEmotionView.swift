import SwiftUI

struct DreamEmotionView: View {
    var analysis: DreamEmotionAnalysis
    var motif: DreamMotif
    var body: some View {
        if analysis.isValid {
            VStack(alignment: .leading, spacing: 8) {
                Text(analysis.present.isEmpty ? "No clear emotion suggested" : analysis.summary)
                    .font(.subheadline).fontWeight(.medium)
                if analysis.suggestedMotif == motif { Text(analysis.visualExplanation).font(.footnote) }
                Text("Suggested from your words by DReAMy. Does it fit how you felt? You can change the portrait in Edit.")
                    .font(.footnote).foregroundStyle(Color("SecondaryInk"))
                if analysis.truncated {
                    Text("Emotion suggestions use the beginning of this long story.").font(.footnote)
                }
            }
        }
    }
}
