import Testing

@testable import FundamentalDocument

extension DocumentSessionSequenceTests
{
    func applied(
        _ transition: DocumentSessionTransition
    ) throws -> EditableDocumentSnapshot
    {
        guard case let .applied(.editable(editable)) = transition
        else
        {
            Issue.record("Expected an applied editable state")
            throw SessionTestFailure.expectedEditable
        }
        return editable
    }

    func expect(
        _ editable: EditableDocumentSnapshot,
        spelling: String,
        revision: UInt64,
        generation: UInt64
    ) throws
    {
        let document = editable.snapshot.document
        let block = try #require(EditableSemanticBlock(
            document.content.firstBlock.block
        ))
        let text = block.runs.map(\.text).joined()
        #expect(Array(text.utf16) == Array(spelling.utf16))
        #expect(document.revision.value == revision)
        #expect(editable.snapshot.generation.value == generation)
    }
}
