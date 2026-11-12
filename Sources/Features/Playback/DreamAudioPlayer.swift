import AVFoundation
import Observation

@MainActor @Observable
final class DreamAudioPlayer {
  var isPlaying = false
  var isPreparing = false
  var error: String?
  private var player: AVAudioPlayer?
  private var sessionIsActive = false
  private var deactivation: Task<Void, Never>?

  func toggle(filename: String) async {
    guard !isPreparing else { return }
    if isPlaying {
      stop()
      return
    }
    isPreparing = true
    defer { isPreparing = false }
    await deactivation?.value
    let url = URL.documentsDirectory.appending(path: "audio").appending(path: filename)
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback)
      guard try await session.activate(options: []) else { throw CocoaError(.featureUnsupported) }
      sessionIsActive = true
      try Task.checkCancellation()
      let player = try AVAudioPlayer(contentsOf: url)
      self.player = player
      isPlaying = player.play()
      guard isPlaying else { throw CocoaError(.fileReadCorruptFile) }
    } catch is CancellationError { stop() } catch {
      self.error = "This recording could not be played."
      stop()
    }
  }

  func monitor() async {
    guard let current = player else { return }
    while isPlaying && !Task.isCancelled {
      if !current.isPlaying {
        if player === current { stop() }
        return
      }
      do { try await Task.sleep(for: .milliseconds(150)) } catch { return }
    }
  }

  func stop() {
    player?.stop()
    player = nil
    isPlaying = false
    if sessionIsActive {
      sessionIsActive = false
      deactivation = Task { _ = try? await AVAudioSession.sharedInstance().deactivate(options: []) }
    }
  }
}
