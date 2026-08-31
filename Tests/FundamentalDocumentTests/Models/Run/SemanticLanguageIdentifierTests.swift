import Testing

@testable import FundamentalDocument

@Suite("A semantic language identifier")
struct SemanticLanguageIdentifierTests
{
    @Test("a nonblank identifier preserves its exact value")
    func nonblankIdentifierPreservesExactValue() throws
    {
        let identifier = try #require(
            SemanticLanguageIdentifier("  hy  ")
        )

        #expect(identifier.value == "  hy  ")
    }

    @Test("blank identifiers are refused")
    func blankIdentifiersAreRefused()
    {
        for value in ["", " ", "\t\n"]
        {
            #expect(SemanticLanguageIdentifier(value) == nil)
        }
    }
}
