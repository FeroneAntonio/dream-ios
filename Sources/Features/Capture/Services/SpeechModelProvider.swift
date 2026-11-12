import Speech

@MainActor
enum SpeechModelProvider {
  static func prepareEnglish() async throws -> SpeechTranscriber {
    guard SpeechTranscriber.isAvailable,
      let locale = await SpeechTranscriber.supportedLocale(
        equivalentTo: Locale(identifier: "en-US"))
    else {
      throw CocoaError(.featureUnsupported)
    }
    let transcriber = SpeechTranscriber(locale: locale, preset: .progressiveTranscription)
    if let download = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
      try await download.downloadAndInstall()
    }
    try Task.checkCancellation()
    return transcriber
  }
}
