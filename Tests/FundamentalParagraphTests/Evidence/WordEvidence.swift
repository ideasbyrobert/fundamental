@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Foundation

enum WordEvidence
{
    static func observe(
        _ name: String, source: ParagraphWordSource,
        language: NativeWordLanguage = .english
    ) throws -> NativeParagraphWords
    {
        let words = try NativeParagraphWords(source: source, language: language)
        guard let directory = ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_PARAGRAPH_CAPTURE_DIR"
        ]
        else
        {
            return words
        }
        let output = URL(fileURLWithPath: directory)
            .appendingPathComponent("observations")
            .appendingPathComponent(name + ".json")
        guard !FileManager.default.fileExists(atPath: output.path)
        else
        {
            throw WordFixtureFailure.invalidValue
        }
        try FileManager.default.createDirectory(
            at: output.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let record: [String: Any] = [
            "name": name,
            "nativeLanguage": language.rawValue,
            "sourceUTF16": source.source.utf16,
            "returnedUTF16": words.returnedUTF16,
            "runs": try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(source.paragraph.runs)
            ),
            "effectiveLanguages": source.spans.map
            {
                Array($0.language.value.utf16)
            },
            "tokens": words.observations.map
            {
                ["flags": $0.flags, "scope": describe($0.resolution)]
            }
        ]
        try JSONSerialization.data(
            withJSONObject: record, options: [.sortedKeys, .prettyPrinted]
        ).write(to: output, options: .atomic)
        return words
    }
}
