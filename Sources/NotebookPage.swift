import SwiftUI

struct NotebookPage: View {
    var entry: DreamEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.date, format: .dateTime.day().month(.wide).year())
                    Spacer()
                    Image(systemName: "moon").accessibilityHidden(true)
                }
                .font(.custom("Noteworthy-Light", size: 17, relativeTo: .body))
                .foregroundStyle(Color(red: 0.38, green: 0.35, blue: 0.31))
                DreamCanvas(seed: entry.seed, feeling: entry.feeling, intensity: entry.intensity,
                            motif: entry.motif, heartRate: nil)
                    .aspectRatio(1.12, contentMode: .fit)
                    .background(Color(red: 0.045, green: 0.047, blue: 0.055))
                    .rotationEffect(.degrees(-1.5))
                    .padding(.horizontal, 8)
                    .accessibilityLabel("The shape of this night: \(entry.motif.name)")
                if let title = entry.title, !title.isEmpty {
                    Text(title).font(.custom("Noteworthy-Bold", size: 25, relativeTo: .title2))
                }
                if let filename = entry.audioFilename { DreamAudioPlayback(filename: filename) }
                Text(entry.text)
                    .font(.custom("Noteworthy-Light", size: 21, relativeTo: .body))
                    .lineSpacing(7).textSelection(.enabled)
                if entry.usedAI {
                    HStack {
                    Text("Visual mood: \(entry.feeling.label.lowercased())")
                        .font(.custom("Noteworthy-Light", size: 17, relativeTo: .body))
                    Spacer()
                    }
                }
                NavigationLink(value: entry.id) { Label("Open this dream", systemImage: "arrow.up.right") }
                    .font(.footnote).foregroundStyle(Color(red: 0.32, green: 0.27, blue: 0.24))
                    .frame(minHeight: 44)
            }
            .padding(28)
            .frame(maxWidth: 620, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background {
            NotebookPaper()
        }
        .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.21))
        .clipShape(.rect(cornerRadius: 3))
        .padding(.horizontal, 20).padding(.vertical, 16)
        .environment(\.colorScheme, .light)
    }
}
