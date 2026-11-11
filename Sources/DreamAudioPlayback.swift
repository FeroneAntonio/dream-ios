import SwiftUI

struct DreamAudioPlayback: View {
    var filename: String
    @State private var player = DreamAudioPlayer()
    @State private var request = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(player.isPlaying ? "Stop" : "Play recording", systemImage: player.isPlaying ? "stop.fill" : "play.fill", action: toggle)
                .frame(minHeight: 44).disabled(player.isPreparing)
            if let error = player.error { Text(error).font(.footnote) }
        }
        .task(id: request, play)
        .task(id: player.isPlaying, player.monitor)
        .onDisappear(perform: player.stop)
    }
    private func toggle() {
        if player.isPlaying { player.stop() } else { request += 1 }
    }
    private func play() async { if request > 0 { await player.toggle(filename: filename) } }
}
