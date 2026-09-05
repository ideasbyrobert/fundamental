import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    func applied(
        _ command: DocumentSessionCommand,
        to state: DocumentSessionState
    ) throws -> EditableDocumentSnapshot
    {
        let result = DocumentSessionTransition(command, in: state)
        guard case let .applied(.editable(editable)) = result
        else
        {
            Issue.record("Expected an applied canonical transition")
            throw WritingTestFailure.expectedEditable
        }
        return editable
    }

    func expect(
        _ editable: EditableDocumentSnapshot,
        text: String,
        revision: UInt64,
        generation: UInt64
    ) throws
    {
        let projection = try #require(WritingProjection(.editable(editable)))
        #expect(Array(projection.text.utf16) == Array(text.utf16))
        #expect(editable.snapshot.document.revision.value == revision)
        #expect(editable.snapshot.generation.value == generation)
    }
}
