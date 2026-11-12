#if DEBUG
  import Foundation
  import FoundationModels
  import AVFoundation
  import Speech

  @MainActor
  enum InterpretationProbe {
    static func runIfRequested() async {
      let arguments = ProcessInfo.processInfo.arguments
      let verifyAI = arguments.contains("--verify-interpretation")
      guard verifyAI || arguments.contains("--verify-speech") else { return }
      let file = URL.documentsDirectory.appending(path: "verification-status.json")
      var status: [String: String] = [
        "stage": "starting", "model": String(describing: SystemLanguageModel.default.availability),
      ]
      func write() {
        if let data = try? JSONSerialization.data(
          withJSONObject: status, options: [.prettyPrinted, .sortedKeys])
        {
          try? data.write(to: file, options: [.atomic, .completeFileProtection])
        }
      }
      write()
      if verifyAI {
        let composer = DreamComposer(recoverDraft: false)
        composer.text =
          "I was walking through a house where the rooms kept changing. I felt lost at first, then found a quiet garden and felt relieved."
        await composer.create()
        status["interpretationGenerated"] = String(composer.result?.usedAI ?? false)
        status["title"] = composer.result?.title ?? ""
        status["reading"] = composer.result?.reflection ?? ""
        status["motif"] = composer.result?.motif.name ?? ""
      }
      status["stage"] = "preparing-English-dictation"
      write()
      do {
        let transcriber = try await SpeechModelProvider.prepareEnglish()
        status["speechAssetsReady"] = "true"
        if let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])
        {
          status["speechPCMFormat"] = String(format.commonFormat.rawValue)
          status["speechSampleRate"] = String(format.sampleRate)
        }
        let fixture = URL.documentsDirectory.appending(path: "verification-speech.caf")
        if FileManager.default.fileExists(atPath: fixture.path()) {
          status["stage"] = "transcribing-synthetic-fixture"
          write()
          let analyzer = SpeechAnalyzer(modules: [transcriber])
          async let text = collect(transcriber)
          try await analyzer.start(
            inputAudioFile: AVAudioFile(forReading: fixture), finishAfterFile: true)
          status["speechTranscript"] = try await text
          try? FileManager.default.removeItem(at: fixture)
        }
      } catch {
        status["speechError"] = "\((error as NSError).domain):\((error as NSError).code)"
      }
      status["stage"] = "complete"
      write()
    }

    private static func collect(_ transcriber: SpeechTranscriber) async throws -> String {
      var transcript = DreamTranscript()
      var text = ""
      for try await result in transcriber.results {
        text = transcript.accept(
          start: result.range.start.seconds, text: String(result.text.characters),
          isFinal: result.isFinal)
      }
      return text
    }
  }
#endif
