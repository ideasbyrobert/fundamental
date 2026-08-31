import Testing

@testable import FundamentalDocument

@Suite("A plain semantic code block")
struct PlainSemanticCodeBlockTests
{
    @Test("initialization preserves immutable ordered runs")
    func initializationPreservesImmutableOrderedRuns()
    {
        let runs = [
            SemanticRun(text: "let value = 1"),
            SemanticRun(text: "\nprint(value)")
        ]
        let block = PlainSemanticCodeBlock(runs: runs)

        #expect(block.runs == runs)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let originalRun = SemanticRun(text: "Original")
        let replacementRun = SemanticRun(text: "Replacement")
        let original = PlainSemanticCodeBlock(runs: [originalRun])
        let replacement = PlainSemanticCodeBlock(runs: [replacementRun])

        #expect(original.runs == [originalRun])
        #expect(replacement.runs == [replacementRun])
    }
}
