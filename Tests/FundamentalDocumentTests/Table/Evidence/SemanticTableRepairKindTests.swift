import Testing

@testable import FundamentalDocument

@Suite("Semantic table repair kinds")
struct SemanticTableRepairKindTests
{
    @Test("the vocabulary and raw values are exact")
    func vocabularyAndRawValuesAreExact()
    {
        #expect(SemanticTableRepairKind.allCases == [
            .nonpositiveRowSpanNormalizedToOne,
            .nonpositiveColumnSpanNormalizedToOne,
            .headerRowCountClamped,
            .contradictoryCellHeaderFlagDiscarded,
            .blankSourceLocationDiscarded
        ])
        #expect(SemanticTableRepairKind.allCases.map(\.rawValue) == [
            "nonpositiveRowSpanNormalizedToOne",
            "nonpositiveColumnSpanNormalizedToOne",
            "headerRowCountClamped",
            "contradictoryCellHeaderFlagDiscarded",
            "blankSourceLocationDiscarded"
        ])
    }

    @Test("an unknown raw value is refused")
    func unknownRawValueIsRefused()
    {
        #expect(SemanticTableRepairKind(rawValue: "unknown") == nil)
    }
}
