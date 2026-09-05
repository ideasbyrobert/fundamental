import Testing

@testable import FundamentalDocument

extension SessionHistoryTestDriver
{
    func applied(
        _ result: DocumentSessionTransition
    ) throws -> EditableDocumentSnapshot
    {
        guard case let .applied(.editable(editable)) = result
        else
        {
            Issue.record("Expected an applied editable transition")
            throw SessionTestFailure.expectedEditable
        }
        return editable
    }

    @discardableResult
    func select(_ start: Int, _ end: Int) throws -> EditableDocumentSnapshot
    {
        try applied(session.submit(.select(
            session.observation,
            DocumentSelection(range: range(start, end))
        )))
    }

    func expect(
        _ spelling: String,
        revision: UInt64,
        generation: UInt64
    ) throws
    {
        let snapshot = try snapshot()
        let document = snapshot.snapshot.document
        #expect(document.content.blocks.count == 1)
        let block = try #require(EditableSemanticBlock(
            document.content.firstBlock.block
        ))
        #expect(Array(block.runs.map(\.text).joined().utf16) ==
            Array(spelling.utf16))
        #expect(document.revision.value == revision)
        #expect(snapshot.snapshot.generation.value == generation)
        #expect(snapshot.selection.range.revision == document.revision)
    }
}
