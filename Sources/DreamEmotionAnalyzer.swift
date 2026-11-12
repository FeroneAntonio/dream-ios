import CoreML
import Foundation
import NaturalLanguage

enum DreamEmotionAnalyzer {
    @concurrent static func analyze(_ text: String) async throws -> DreamEmotionAnalysis {
        try Task.checkCancellation()
        // The English checkpoint is not silently applied to other languages.
        guard NLLanguageRecognizer.dominantLanguage(for: text) == .english else { throw CocoaError(.featureUnsupported) }
        guard let url = Bundle.main.url(forResource: "DreamyEmotion", withExtension: "mlmodelc"),
              let vocabulary = Bundle.main.url(forResource: "dreamy-vocab", withExtension: "txt") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let configuration = MLModelConfiguration()
        #if targetEnvironment(simulator)
        configuration.computeUnits = .cpuOnly
        #else
        configuration.computeUnits = .all
        #endif
        // Each request owns its model: no non-Sendable cached reference crosses
        // an async prediction boundary, and weights need not remain resident.
        let model = try await MLModel.load(contentsOf: url, configuration: configuration)
        try Task.checkCancellation()
        let metadata = model.modelDescription.metadata[.creatorDefinedKey] as? [String: String]
        guard metadata?["huggingface_revision"] == DreamEmotionAnalysis.revision else {
            throw CocoaError(.coderInvalidValue)
        }
        let tokenizer = try DreamBERTTokenizer(vocabulary: String(contentsOf: vocabulary, encoding: .utf8))
        let tokens = tokenizer.encode(text)
        var values: [String: MLFeatureValue] = [:]
        for (name, integers) in [("input_ids", tokens.ids), ("attention_mask", tokens.mask), ("token_type_ids", [Int32](repeating: 0, count: 512))] {
            let array = try MLMultiArray(shape: [1, 512], dataType: .int32)
            for index in integers.indices { array[index] = NSNumber(value: integers[index]) }
            values[name] = MLFeatureValue(multiArray: array)
        }
        let prediction = try await model.prediction(from: MLDictionaryFeatureProvider(dictionary: values))
        try Task.checkCancellation()
        guard let output = prediction.featureValue(for: "logits")?.multiArrayValue, output.count == 5 else {
            throw CocoaError(.coderInvalidValue)
        }
        return try DreamEmotionAnalysis(logits: (0..<5).map { output[$0].doubleValue }, truncated: tokens.truncated)
    }
}
