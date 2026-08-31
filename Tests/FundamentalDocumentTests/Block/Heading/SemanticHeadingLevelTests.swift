import Testing

@testable import FundamentalDocument

@Suite("A semantic heading level")
struct SemanticHeadingLevelTests
{
    @Test("the six levels are exact and ordered")
    func vocabularyIsExact()
    {
        #expect(SemanticHeadingLevel.allCases == [
            .one,
            .two,
            .three,
            .four,
            .five,
            .six
        ])
        #expect(SemanticHeadingLevel.allCases.map(\.rawValue) == [
            1,
            2,
            3,
            4,
            5,
            6
        ])
    }

    @Test("every integer from one through six is admitted exactly")
    func validRawValuesAreAdmitted()
    {
        for (rawValue, level) in zip(
            1...6,
            SemanticHeadingLevel.allCases
        )
        {
            #expect(SemanticHeadingLevel(rawValue: rawValue) == level)
        }
    }

    @Test("integers outside one through six are refused")
    func outOfRangeRawValuesAreRefused()
    {
        for rawValue in [Int.min, -1, 0, 7, Int.max]
        {
            #expect(SemanticHeadingLevel(rawValue: rawValue) == nil)
        }
    }
}
