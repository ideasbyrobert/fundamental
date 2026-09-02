import Testing

@testable import FundamentalDocument

extension EditableDocumentSnapshotTests
{
    @Test("terminal generation does not prevent editing admission")
    func terminalGenerationDoesNotPreventAdmission() throws
    {
        let snapshot = try DocumentSnapshotTests.snapshot(
            generation: UInt64.max,
            blocks: [(2, DocumentSnapshotTests.editableBlock(.paragraph))]
        )
        let selection = try DocumentSnapshotTests.selection()

        #expect(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ) != nil)
    }

    @Test("generation and revision need no numeric relationship")
    func generationAndRevisionNeedNoNumericRelationship() throws
    {
        let snapshot = try DocumentSnapshotTests.snapshot(
            generation: 1,
            revision: UInt64.max,
            blocks: [(2, DocumentSnapshotTests.editableBlock(.paragraph))]
        )
        let selection = try DocumentSnapshotTests.selection(
            revision: UInt64.max
        )

        #expect(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ) != nil)
    }

    @Test("refusal leaves the readable snapshot intact")
    func refusalLeavesReadableSnapshotIntact() throws
    {
        let block = try DocumentSnapshotTests.tableBlock(.sourcedRegular)
        let snapshot = try DocumentSnapshotTests.snapshot(blocks: [(2, block)])
        let selection = try DocumentSnapshotTests.selection()

        #expect(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ) == nil)
        #expect(snapshot.document.content.blocks[0].block == block)
    }
}
