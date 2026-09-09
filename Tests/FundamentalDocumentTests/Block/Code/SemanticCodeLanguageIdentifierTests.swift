import Testing

@testable import FundamentalDocument

@Suite("A semantic code language identifier")
struct SemanticCodeLanguageIdentifierTests
{
    @Test("nonblank identifiers preserve their exact value")
    func nonblankIdentifiersPreserveExactValues() throws
    {
        for value in ["swift", " c++ ", "objective-c", "  x"]
        {
            let identifier = try #require(
                SemanticCodeLanguageIdentifier(value)
            )

            #expect(identifier.value == value)
        }
    }

    @Test("empty and whitespace only identifiers are refused")
    func blankIdentifiersAreRefused()
    {
        for value in ["", " ", "\t", "\n", "\u{00A0}"]
        {
            #expect(SemanticCodeLanguageIdentifier(value) == nil)
        }
    }

    @Test("identifier equality retains raw spelling instead of normalizing it")
    func exactEquality() throws
    {
        let composed = try #require(SemanticCodeLanguageIdentifier("é"))
        let decomposed = try #require(
            SemanticCodeLanguageIdentifier("e\u{301}")
        )
        #expect(composed.value == decomposed.value)
        #expect(composed != decomposed)
        #expect(composed == SemanticCodeLanguageIdentifier("é"))
        #expect(decomposed == SemanticCodeLanguageIdentifier("e\u{301}"))
    }
}
