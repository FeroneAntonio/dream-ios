import Foundation

struct DreamBERTTokenizer: Sendable {
    private let vocabulary: [String: Int32]
    private let special = ["[UNK]", "[SEP]", "[PAD]", "[CLS]", "[MASK]"]

    init(vocabulary text: String) throws {
        let words = text.components(separatedBy: "\n")
        guard words.count >= 28_996, words[0] == "[PAD]", words[100] == "[UNK]",
              words[101] == "[CLS]", words[102] == "[SEP]", words[103] == "[MASK]" else {
            throw CocoaError(.coderInvalidValue)
        }
        vocabulary = Dictionary(uniqueKeysWithValues: words.prefix(28_996).enumerated().map { ($1, Int32($0)) })
    }

    func encode(_ text: String) -> DreamBERTTokens {
        var ids: [Int32] = []
        var remaining = text[...]
        // Hugging Face isolates added special tokens before basic tokenization.
        while !remaining.isEmpty {
            let match = special.compactMap { token in remaining.range(of: token).map { ($0, token) } }
                .min { $0.0.lowerBound < $1.0.lowerBound }
            guard let (range, token) = match else {
                ids += basicTokens(String(remaining)).flatMap(wordPiece)
                break
            }
            ids += basicTokens(String(remaining[..<range.lowerBound])).flatMap(wordPiece)
            ids.append(vocabulary[token] ?? 100)
            remaining = remaining[range.upperBound...]
        }
        let truncated = ids.count > 510
        ids = [101] + Array(ids.prefix(510)) + [102]
        let count = ids.count
        ids += Array(repeating: 0, count: 512 - count)
        return DreamBERTTokens(ids: ids, mask: Array(repeating: 1, count: count) + Array(repeating: 0, count: 512 - count), truncated: truncated)
    }

    private func basicTokens(_ text: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        func flush() { if !current.isEmpty { tokens.append(current); current = "" } }
        for scalar in text.unicodeScalars {
            let value = scalar.value
            let category = scalar.properties.generalCategory
            if value == 0 || value == 0xFFFD { continue }
            if value == 9 || value == 10 || value == 13 || value == 32 || category == .spaceSeparator {
                flush()
            } else if category == .control || category == .format {
                continue
            } else if Self.isChinese(value) || Self.isPunctuation(scalar) {
                flush(); tokens.append(String(scalar))
            } else { current.unicodeScalars.append(scalar) }
        }
        flush()
        return tokens
    }

    private func wordPiece(_ token: String) -> [Int32] {
        let scalars = Array(token.unicodeScalars)
        guard scalars.count <= 100 else { return [100] }
        var pieces: [Int32] = []
        var start = 0
        while start < scalars.count {
            var end = scalars.count
            var found: Int32?
            while start < end {
                let word = (start > 0 ? "##" : "") + String(String.UnicodeScalarView(scalars[start..<end]))
                if let id = vocabulary[word] { found = id; break }
                end -= 1
            }
            guard let found else { return [100] }
            pieces.append(found)
            start = end
        }
        return pieces
    }

    private static func isPunctuation(_ scalar: Unicode.Scalar) -> Bool {
        if (33...47).contains(scalar.value) || (58...64).contains(scalar.value) ||
            (91...96).contains(scalar.value) || (123...126).contains(scalar.value) { return true }
        return switch scalar.properties.generalCategory {
        case .connectorPunctuation, .dashPunctuation, .openPunctuation, .closePunctuation,
             .initialPunctuation, .finalPunctuation, .otherPunctuation: true
        default: false
        }
    }
    private static func isChinese(_ value: UInt32) -> Bool {
        [(0x4E00...0x9FFF), (0x3400...0x4DBF), (0x20000...0x2A6DF), (0x2A700...0x2B73F),
         (0x2B740...0x2B81F), (0x2B820...0x2CEAF), (0xF900...0xFAFF), (0x2F800...0x2FA1F)]
            .contains { $0.contains(Int(value)) }
    }
}
