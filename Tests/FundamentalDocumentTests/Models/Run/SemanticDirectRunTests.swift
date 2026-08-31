import Testing

@testable import FundamentalDocument

@Suite("A direct semantic run")
struct SemanticDirectRunTests
{
    @Test("initialization preserves its immutable facts")
    func initializationPreservesImmutableFacts()
    {
        let run = SemanticDirectRun(
            text: "Բարև 😀",
            traits: [.strong, .emphasis]
        )

        #expect(run.text == "Բարև 😀")
        #expect(run.traits == [.strong, .emphasis])
    }
}
