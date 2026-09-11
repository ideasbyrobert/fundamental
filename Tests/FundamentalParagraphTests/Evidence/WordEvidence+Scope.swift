@testable import FundamentalParagraph
import FundamentalNativeParagraph
extension WordEvidence
{
    static func describe(_ resolution: WordScopeResolution) -> [String: Any]
    {
        let range = resolution.range
        var result: [String: Any] = [
            "range": [range.lowerBound, range.upperBound]
        ]
        switch resolution
        {
        case let .resolved(scope):
            result["status"] = "resolved"
            result["languageUTF16"] = Array(scope.language.value.utf16)
            result["fragments"] = scope.fragments.map
            {
                [
                    "run": $0.runIndex,
                    "paragraph": [
                        $0.paragraphRange.lowerBound,
                        $0.paragraphRange.upperBound
                    ],
                    "local": [$0.runRange.lowerBound, $0.runRange.upperBound]
                ] as [String: Any]
            }
        case let .refused(_, reasons):
            result["status"] = "refused"
            result["reasons"] = reasons.map { String(reflecting: $0) }
        }
        return result
    }
}
