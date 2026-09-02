import Testing

@testable import FundamentalDocument

@Suite("An editable document snapshot")
struct EditableDocumentSnapshotTests
{
    @Test(
        "every editable block form is admitted",
        arguments: EditableDocumentBlockForm.allCases
    )
    func everyEditableBlockFormIsAdmitted(
        _ form: EditableDocumentBlockForm
    ) throws
    {
        let snapshot = try DocumentSnapshotTests.snapshot(
            blocks: [(2, DocumentSnapshotTests.editableBlock(form))]
        )
        let selection = try DocumentSnapshotTests.selection()

        #expect(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ) != nil)
    }

    @Test("reverse cross-block selection remains exact")
    func reverseCrossBlockSelectionRemainsExact() throws
    {
        let snapshot = try DocumentSnapshotTests.snapshot(blocks: [
            (2, DocumentSnapshotTests.editableBlock(.paragraph)),
            (3, DocumentSnapshotTests.editableBlock(.code))
        ])
        let selection = try DocumentSnapshotTests.selection(
            startBlock: 3,
            startOffset: 4,
            endBlock: 2,
            endOffset: 1
        )
        let editable = try #require(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ))

        #expect(editable.selection == selection)
    }

    @Test("every required component participates in equality")
    func everyComponentParticipatesInEquality() throws
    {
        let block = DocumentSnapshotTests.editableBlock(.paragraph)
        let snapshot = try DocumentSnapshotTests.snapshot(blocks: [(2, block)])
        let selection = try DocumentSnapshotTests.selection()
        let base = try #require(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ))
        let changedSelection = try DocumentSnapshotTests.selection(endOffset: 1)
        let variants = [
            try #require(EditableDocumentSnapshot(
                snapshot: try DocumentSnapshotTests.snapshot(
                    generation: 4,
                    blocks: [(2, block)]
                ),
                selection: selection
            )),
            try #require(EditableDocumentSnapshot(
                snapshot: snapshot,
                selection: changedSelection
            ))
        ]

        #expect(variants.allSatisfy { $0 != base })
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let snapshot = try DocumentSnapshotTests.snapshot(
            blocks: [(2, DocumentSnapshotTests.editableBlock(.paragraph))]
        )
        let originalSelection = try DocumentSnapshotTests.selection()
        let original = try #require(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: originalSelection
        ))
        let changed = try #require(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: try DocumentSnapshotTests.selection(endOffset: 2)
        ))

        #expect(original.selection == originalSelection)
        #expect(original != changed)
    }
}
