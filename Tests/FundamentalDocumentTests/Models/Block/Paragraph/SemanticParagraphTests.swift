import Testing

@testable import FundamentalDocument

@Suite("A semantic paragraph")
struct SemanticParagraphTests
{
    @Test("an empty paragraph is an admitted value")
    func emptyParagraphIsAdmitted()
    {
        let paragraph = SemanticParagraph(runs: [])

        #expect(paragraph.runs.isEmpty)
    }

    @Test("initialization preserves immutable ordered runs")
    func initializationPreservesImmutableOrderedRuns() throws
    {
        let destination = try #require(
            SemanticLinkDestination("chapter/one")
        )
        let runs: [SemanticRun] = [
            SemanticRun(
                text: "First",
                traits: [.strong]
            ),
            .scoped(
                SemanticScopedRun(
                    text: "Second",
                    traits: [.emphasis],
                    scopes: .link(destination)
                )
            )
        ]
        let paragraph = SemanticParagraph(runs: runs)

        #expect(paragraph.runs == runs)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let originalRun = SemanticRun(text: "Original")
        let replacementRun = SemanticRun(text: "Replacement")
        let original = SemanticParagraph(runs: [originalRun])
        let replacement = SemanticParagraph(runs: [replacementRun])

        #expect(original.runs == [originalRun])
        #expect(replacement.runs == [replacementRun])
    }
}
