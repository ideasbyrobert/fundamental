@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Foundation

enum OwnedEvidence
{
    static func spellingName(_ text: String) -> String
    {
        text.utf16.map { String($0, radix: 16) }.joined(separator: "-")
    }

    static func observe(
        _ name: String, source: ParagraphWordSource,
        language: NativeWordLanguage = .english
    ) throws -> OwnedExperiment
    {
        let words = try NativeParagraphWords(source: source, language: language)
        var requests: [PatternResult] = []
        let collection = try ParagraphOwnedCandidates(
            words, catalog: OwnedFixture.catalog()
        )
        {
            dictionary, text in
            let result = try dictionary.hyphenate(text)
            requests.append(result)
            return result
        }
        try PatternEvidence.write(name, group: "owned", record: [
            "policyVersion": ParagraphOwnedCandidates.policyVersion,
            "caseLocale": LowercaseWordLookup.localeIdentifier,
            "nativeLanguage": language.rawValue,
            "sourceUTF16": source.source.utf16,
            "returnedUTF16": words.returnedUTF16,
            "runs": try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(source.paragraph.runs)
            ),
            "records": collection.records.map
            {
                [
                    "scope": WordEvidence.describe($0.word.resolution),
                    "flags": $0.word.flags,
                    "outcome": describe($0.outcome)
                ] as [String: Any]
            },
            "requests": requests.map(PatternEvidence.describe)
        ])
        return OwnedExperiment(collection: collection, requests: requests)
    }

    static func describe(_ lookup: LowercaseWordLookup) -> [String: Any]
    {
        [
            "sourceRange": [
                lookup.normalized.sourceRange.lowerBound,
                lookup.normalized.sourceRange.upperBound
            ],
            "sourceUTF16": lookup.normalized.sourceUTF16,
            "normalizedUTF16": Array(lookup.normalized.text.utf16),
            "lowercaseUTF16": Array(lookup.text.utf16),
            "boundaries": lookup.boundaries.map { [$0.source, $0.lookup] }
        ]
    }
}
