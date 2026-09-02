import Testing

@testable import FundamentalDocument

extension EditableDocumentSnapshotTests
{
    @Test("construction preserves the exact snapshot and selection")
    func constructionPreservesExactValues() throws
    {
        let snapshot = try Self.snapshot()
        let selection = try DocumentSnapshotTests.selection(endOffset: 2)
        let editable = try #require(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ))

        #expect(editable.snapshot == snapshot)
        #expect(editable.selection == selection)
    }

    @Test("a runless paragraph admits a caret at zero")
    func runlessParagraphAdmitsCaretAtZero() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: []))
        let snapshot = try DocumentSnapshotTests.snapshot(blocks: [(2, block)])
        let selection = try DocumentSnapshotTests.selection()

        #expect(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ) != nil)
    }

    @Test("forward cross-block selection remains exact")
    func forwardCrossBlockSelectionRemainsExact() throws
    {
        let snapshot = try DocumentSnapshotTests.snapshot(blocks: [
            (2, DocumentSnapshotTests.editableBlock(.paragraph)),
            (3, DocumentSnapshotTests.editableBlock(.code))
        ])
        let selection = try DocumentSnapshotTests.selection(
            startBlock: 2,
            startOffset: 1,
            endBlock: 3,
            endOffset: 4
        )
        let editable = try #require(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ))

        #expect(editable.selection == selection)
    }

    @Test("a selection may span every editable block form")
    func selectionMaySpanEveryEditableBlockForm() throws
    {
        let snapshot = try DocumentSnapshotTests.snapshot(blocks: [
            (2, DocumentSnapshotTests.editableBlock(.paragraph)),
            (3, DocumentSnapshotTests.editableBlock(.heading)),
            (4, DocumentSnapshotTests.editableBlock(.code))
        ])
        let selection = try DocumentSnapshotTests.selection(
            startBlock: 2,
            endBlock: 4,
            endOffset: 4
        )

        #expect(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ) != nil)
    }

    private static func snapshot() throws -> DocumentSnapshot
    {
        try DocumentSnapshotTests.snapshot(blocks: [
            (2, DocumentSnapshotTests.editableBlock(.paragraph))
        ])
    }
}
