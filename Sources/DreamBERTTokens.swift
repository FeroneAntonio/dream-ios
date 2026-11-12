struct DreamBERTTokens: Sendable {
    var ids: [Int32]
    var mask: [Int32]
    var truncated: Bool
}
