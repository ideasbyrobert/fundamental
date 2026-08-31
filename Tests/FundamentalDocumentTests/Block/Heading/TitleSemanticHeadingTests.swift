import Testing

@testable import FundamentalDocument

@Suite("A title semantic heading")
struct TitleSemanticHeadingTests
{
    @Test("initialization preserves immutable ordered runs")
    func initializationPreservesImmutableOrderedRuns()
    {
        let runs = [
            SemanticRun(text: "First"),
            SemanticRun(
                text: "Second",
                traits: [.emphasis]
            )
        ]
        let heading = TitleSemanticHeading(runs: runs)

        #expect(heading.runs == runs)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let originalRun = SemanticRun(text: "Original")
        let replacementRun = SemanticRun(text: "Replacement")
        let original = TitleSemanticHeading(runs: [originalRun])
        let replacement = TitleSemanticHeading(runs: [replacementRun])

        #expect(original.runs == [originalRun])
        #expect(replacement.runs == [replacementRun])
    }
}
