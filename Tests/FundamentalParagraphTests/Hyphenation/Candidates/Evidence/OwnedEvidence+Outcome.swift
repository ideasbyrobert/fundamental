@testable import FundamentalParagraph
extension OwnedEvidence
{
    static func describe(_ outcome: OwnedWordOutcome) -> [String: Any]
    {
        switch outcome
        {
        case .sourceRefused:
            ["status": "sourceRefused"]
        case .tokenAttributes:
            ["status": "tokenAttributes"]
        case let .unsupportedLanguage(value):
            [
                "status": "unsupportedLanguage",
                "requestedUTF16": Array(value.utf16)
            ]
        case let .protectedMarks(marks):
            [
                "status": "protectedMarks",
                "marks": marks.map
                {
                    [
                        "scalar": $0.mark.rawValue,
                        "range": [$0.range.lowerBound, $0.range.upperBound]
                    ] as [String: Any]
                }
            ]
        case let .normalizationRefused(error):
            [
                "status": "normalizationRefused",
                "error": String(reflecting: error)
            ]
        case let .capitalizationRefused(value):
            ["status": "capitalizationRefused", "case": value.rawValue]
        case let .caseMappingRefused(error):
            ["status": "caseMappingRefused", "error": String(reflecting: error)]
        case let .unsupportedAlphabet(language):
            ["status": "unsupportedAlphabet", "language": language.rawValue]
        case let .mappingRefused(lookup, result, error):
            [
                "status": "mappingRefused", "lookup": describe(lookup),
                "raw": PatternEvidence.describe(result),
                "error": String(reflecting: error)
            ]
        case let .candidates(value):
            [
                "status": "candidates", "lookup": describe(value.lookup),
                "raw": PatternEvidence.describe(value.result),
                "candidates": value.candidates.map
                {
                    [
                        "source": $0.sourceOffset,
                        "lookup": $0.lookupOffset,
                        "hyphenScalar": $0.hyphenScalar
                    ] as [String: Any]
                }
            ]
        }
    }
}
