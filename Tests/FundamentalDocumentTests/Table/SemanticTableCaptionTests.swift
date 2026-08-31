import Testing

@testable import FundamentalDocument

@Suite("A semantic table caption")
struct SemanticTableCaptionTests
{
    @Test("initialization preserves the required first run and remaining order")
    func initializationPreservesRequiredFirstRunAndRemainingOrder()
    {
        let firstRun = SemanticRun(text: "")
        let remainingRuns = [
            SemanticRun(text: "First"),
            SemanticRun(text: "Second", traits: [.emphasis])
        ]
        let caption = SemanticTableCaption(
            firstRun: firstRun,
            remainingRuns: remainingRuns
        )

        #expect(caption.firstRun == firstRun)
        #expect(caption.remainingRuns == remainingRuns)
        #expect(caption.runs == [firstRun] + remainingRuns)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let original = SemanticTableCaption(
            firstRun: SemanticRun(text: "Caption"),
            remainingRuns: []
        )
        let changed = SemanticTableCaption(
            firstRun: SemanticRun(text: "Changed"),
            remainingRuns: [SemanticRun(text: "Again")]
        )

        #expect(original != changed)
        #expect(original.firstRun == SemanticRun(text: "Caption"))
        #expect(original.remainingRuns.isEmpty)
        #expect(original.runs.count == 1)
    }
}
