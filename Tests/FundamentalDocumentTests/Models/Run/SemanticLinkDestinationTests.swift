import Testing

@testable import FundamentalDocument

@Suite("A semantic link destination")
struct SemanticLinkDestinationTests
{
    @Test("a nonblank destination preserves its exact value")
    func nonblankDestinationPreservesExactValue() throws
    {
        let destination = try #require(
            SemanticLinkDestination("  chapter one  ")
        )

        #expect(destination.value == "  chapter one  ")
    }

    @Test("blank destinations are refused")
    func blankDestinationsAreRefused()
    {
        for value in ["", " ", "\t\n"]
        {
            #expect(SemanticLinkDestination(value) == nil)
        }
    }
}
