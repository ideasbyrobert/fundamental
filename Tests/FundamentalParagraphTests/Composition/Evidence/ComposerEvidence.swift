import FundamentalNativeParagraph
import Testing

enum ComposerEvidence
{
    static func score(_ value: QualityScore) -> [String: Any]
    {
        ["emergency": value.emergency, "demerits": value.demerits]
    }

    static func equal(_ actual: QualityScore, _ expected: QualityScore)
    {
        #expect(actual.emergency == expected.emergency)
        #expect(abs(actual.demerits - expected.demerits)
                <= max(0.000001, abs(expected.demerits) * 0.000000000001))
    }
}
