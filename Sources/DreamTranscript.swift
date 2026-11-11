struct DreamTranscript {
    private var finalized: [Double: String] = [:]

    mutating func accept(start: Double, text: String, isFinal: Bool) -> String {
        var partial = ""
        if isFinal { finalized[start] = text } else { partial = text }
        let complete = finalized.sorted { $0.key < $1.key }.map(\.value).joined(separator: " ")
        return [complete, partial].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
