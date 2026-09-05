import Testing

@testable import FundamentalDocument

@MainActor
struct SessionHistoryTestDriver
{
    let session: DocumentSession

    init(
        _ fixture: SessionTestDocument,
        limits: DocumentHistoryLimits = DocumentHistoryLimits()
    )
    {
        session = DocumentSession(state: fixture.state, historyLimits: limits)
    }

    var storage: DocumentSessionStorage
    {
        DocumentSessionStorage(state: session.state, history: session.history)
    }

    func snapshot() throws -> EditableDocumentSnapshot
    {
        guard case let .editable(editable) = session.state
        else
        {
            throw SessionTestFailure.expectedEditable
        }
        return editable
    }

    func point(_ offset: Int, block: Int = 0) throws -> DocumentPoint
    {
        let document = session.state.snapshot.document
        return DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: document.content.blocks[block].blockID,
            utf16Offset: try #require(DocumentUTF16Offset(offset))
        )
    }

    func range(_ start: Int, _ end: Int) throws -> DocumentRange
    {
        try #require(DocumentRange(start: point(start), end: point(end)))
    }

    @discardableResult
    func edit(_ edit: CanonicalDocumentEdit) throws -> EditableDocumentSnapshot
    {
        try applied(session.submit(.edit(session.observation, edit)))
    }

    @discardableResult
    func insert(_ text: String, at offset: Int) throws
        -> EditableDocumentSnapshot
    {
        try edit(SessionTestEdit.inserted(text, at: point(offset)))
    }

    @discardableResult
    func move(_ direction: DocumentHistoryDirection) throws
        -> EditableDocumentSnapshot
    {
        try applied(session.submit(DocumentHistoryCommand(
            observation: session.observation,
            direction: direction
        )))
    }
}
