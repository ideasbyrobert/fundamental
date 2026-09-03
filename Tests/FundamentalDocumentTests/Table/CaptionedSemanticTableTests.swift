import Testing

@testable import FundamentalDocument

@Suite("A captioned semantic table")
struct CaptionedSemanticTableTests
{
    @Test("initialization preserves immutable content and caption")
    func initializationPreservesImmutableContentAndCaption() throws
    {
        let content = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [BodySemanticTableRow(cells: [])],
            columnAlignments: [.center]
        ))
        let caption = SemanticTableCaption(
            firstRun: SemanticRun(text: "Caption"),
            remainingRuns: []
        )
        let table = CaptionedSemanticTable(
            content: content,
            caption: caption
        )

        #expect(table.content == content)
        #expect(table.caption == caption)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let content = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: []
        ))
        let original = CaptionedSemanticTable(
            content: content,
            caption: SemanticTableCaption(
                firstRun: SemanticRun(text: "Caption"),
                remainingRuns: []
            )
        )
        let changed = CaptionedSemanticTable(
            content: content,
            caption: SemanticTableCaption(
                firstRun: SemanticRun(text: "Changed"),
                remainingRuns: []
            )
        )

        #expect(original != changed)
        #expect(original.caption.runs == [
            SemanticRun(text: "Caption")
        ])
    }
}
