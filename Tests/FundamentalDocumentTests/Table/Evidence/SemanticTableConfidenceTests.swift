import Testing

@testable import FundamentalDocument

@Suite("Semantic table confidence")
struct SemanticTableConfidenceTests
{
    @Test("finite closed-range values are admitted")
    func finiteClosedRangeValuesAreAdmitted() throws
    {
        for value in [0.0, 0.5, 1.0]
        {
            let confidence = try #require(
                SemanticTableConfidence(value)
            )

            #expect(confidence.value == value)
        }
    }

    @Test("nonfinite and out-of-range values are refused")
    func nonfiniteAndOutOfRangeValuesAreRefused()
    {
        let values = [
            Double.nan,
            Double.infinity,
            -Double.infinity,
            -Double.leastNonzeroMagnitude,
            1.0.nextUp
        ]

        for value in values
        {
            #expect(SemanticTableConfidence(value) == nil)
        }
    }
}
