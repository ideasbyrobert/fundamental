import Testing

@testable import FundamentalDocument

extension EditableDocumentSnapshotTests
{
    @Test("a foreign document selection is refused")
    func foreignDocumentSelectionIsRefused() throws
    {
        let snapshot = try Self.snapshot()
        let selection = try DocumentSnapshotTests.selection(documentMarker: 9)
        #expect(Self.editable(snapshot, selection) == nil)
    }

    @Test("a stale revision selection is refused")
    func staleRevisionSelectionIsRefused() throws
    {
        let snapshot = try Self.snapshot()
        let selection = try DocumentSnapshotTests.selection(revision: 7)
        #expect(Self.editable(snapshot, selection) == nil)
    }

    @Test("a missing block selection is refused")
    func missingBlockSelectionIsRefused() throws
    {
        let snapshot = try Self.snapshot()
        let selection = try DocumentSnapshotTests.selection(startBlock: 9)
        #expect(Self.editable(snapshot, selection) == nil)
    }

    @Test("non-character boundaries are refused")
    func nonCharacterBoundariesAreRefused() throws
    {
        let cases = [
            (text: "\u{1F600}", offset: 1),
            (text: "e\u{301}", offset: 1)
        ]
        for item in cases
        {
            let snapshot = try Self.snapshot(text: item.text)
            let selection = try DocumentSnapshotTests.selection(
                startOffset: item.offset,
                endOffset: item.offset
            )
            #expect(Self.editable(snapshot, selection) == nil)
        }
    }

    private static func snapshot(
        text: String = "Text"
    ) throws -> DocumentSnapshot
    {
        try DocumentSnapshotTests.snapshot(blocks: [
            (2, DocumentSnapshotTests.editableBlock(
                .paragraph,
                text: text
            ))
        ])
    }

    private static func editable(
        _ snapshot: DocumentSnapshot,
        _ selection: DocumentSelection
    ) -> EditableDocumentSnapshot?
    {
        EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        )
    }
}
