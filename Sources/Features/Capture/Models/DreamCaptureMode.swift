enum DreamCaptureMode: String, Identifiable {
  case voice, text
  var id: String { rawValue }
}
