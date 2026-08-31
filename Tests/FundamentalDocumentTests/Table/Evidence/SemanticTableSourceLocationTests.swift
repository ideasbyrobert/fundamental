import Testing

@testable import FundamentalDocument

@Suite("A semantic table source location")
struct SemanticTableSourceLocationTests
{
    @Test("a nonblank location preserves its exact value")
    func nonblankLocationPreservesExactValue() throws
    {
        let location = try #require(
            SemanticTableSourceLocation("  after paragraph 3  ")
        )

        #expect(location.value == "  after paragraph 3  ")
    }

    @Test("blank locations are refused")
    func blankLocationsAreRefused()
    {
        for value in ["", " ", "\t\n"]
        {
            #expect(SemanticTableSourceLocation(value) == nil)
        }
    }
}
