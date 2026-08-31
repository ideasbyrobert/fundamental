import Testing

@testable import FundamentalDocument

@Suite("A scoped semantic run")
struct SemanticScopedRunTests
{
    @Test("initialization preserves its immutable facts")
    func initializationPreservesImmutableFacts() throws
    {
        let language = try #require(SemanticLanguageIdentifier("hy"))
        let run = SemanticScopedRun(
            text: "Բարև 😀",
            traits: [.emphasis],
            scopes: .language(language)
        )

        #expect(run.text == "Բարև 😀")
        #expect(run.traits == [.emphasis])
        #expect(run.scopes == .language(language))
    }
}
