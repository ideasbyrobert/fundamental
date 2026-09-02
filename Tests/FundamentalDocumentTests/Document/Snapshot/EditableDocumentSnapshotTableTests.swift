import Testing

@testable import FundamentalDocument

extension EditableDocumentSnapshotTests
{
    @Test(
        "every table record form is refused",
        arguments: DocumentSnapshotTableForm.allCases
    )
    func everyTableRecordFormIsRefused(
        _ form: DocumentSnapshotTableForm
    ) throws
    {
        let block = try DocumentSnapshotTests.tableBlock(form)
        let snapshot = try DocumentSnapshotTests.snapshot(blocks: [(2, block)])
        let selection = try DocumentSnapshotTests.selection()

        #expect(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ) == nil)
    }

    @Test(
        "a table anywhere makes the document read-only",
        arguments: [0, 1, 2]
    )
    func tableAnywhereMakesDocumentReadOnly(
        _ tableIndex: Int
    ) throws
    {
        var blocks: [(UInt8, SemanticBlock)] = [
            (2, DocumentSnapshotTests.editableBlock(.paragraph)),
            (3, DocumentSnapshotTests.editableBlock(.heading)),
            (4, DocumentSnapshotTests.editableBlock(.code))
        ]
        blocks[tableIndex].1 = try DocumentSnapshotTests.tableBlock()
        let selectedIndex = tableIndex == 0 ? 1 : 0
        let selectedMarker = blocks[selectedIndex].0
        let snapshot = try DocumentSnapshotTests.snapshot(blocks: blocks)
        let selection = try DocumentSnapshotTests.selection(
            startBlock: selectedMarker,
            endBlock: selectedMarker
        )

        #expect(snapshot.document.content.blocks.count == 3)
        #expect(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ) == nil)
    }
}
