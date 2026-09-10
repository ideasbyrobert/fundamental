import Testing

@testable import FundamentalDocument

extension DocumentSessionInputTests
{
    @Test("unchanged spelling can complete selection without consuming history")
    func unchangedSpelling() throws
    {
        let fixture = try DocumentInputTestFixture()
        let session = DocumentSession(state: fixture.state,
                                      initiallySaved: true)
        session.submit(.edit(session.observation, fixture.edit))
        session.submit(DocumentHistoryCommand(observation: session.observation,
                                                direction: .undo))
        let before = session.current
        let document = session.document
        let point = DocumentPoint(documentID: document.documentID,
            revision: document.revision,
            blockID: document.content.blocks[0].blockID,
            utf16Offset: try #require(DocumentUTF16Offset(1)))
        let transaction = DocumentInputTransaction(
            selection: .caret(at: point), typingIntent: fixture.intent
        )
        let ticket = session.prepareSave()
        let command = DocumentSessionCommand.input(session.observation,
                                                    transaction)
        #expect(!command.changesContent)
        guard case let .applied(.editable(after)) = session.submit(command)
        else
        {
            Issue.record("Expected input selection completion")
            return
        }
        #expect(after.snapshot.document == document)
        #expect(after.snapshot.generation.value ==
            before.state.snapshot.generation.value + 1)
        #expect(after.typingIntent == fixture.intent)
        #expect(session.history == before.history && session.canRedo)
        #expect(session.acknowledgeSave(ticket) && !session.isDirty)
        let retained = session.current
        #expect(session.submit(.input(session.observation, transaction)) ==
            .unchanged)
        #expect(session.current == retained)
    }

    @Test("exhausted generation permits only an identical input completion")
    func generation() throws
    {
        let fixture = try DocumentInputTestFixture()
        guard case let .editable(source) = fixture.state
        else
        {
            throw SessionTestFailure.expectedEditable
        }
        let exhausted = try #require(EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(generation: SnapshotGeneration(.max),
                                       document: source.snapshot.document),
            selection: source.selection, typingIntent: source.typingIntent
        ))
        let session = DocumentSession(state: .editable(exhausted))
        let unchanged = DocumentInputTransaction(
            selection: source.selection, typingIntent: source.typingIntent
        )
        #expect(session.submit(.input(session.observation, unchanged)) ==
            .unchanged)
        let changed = DocumentInputTransaction(selection: source.selection,
                                                 typingIntent: fixture.intent)
        #expect(session.submit(.input(session.observation, changed)) ==
            .refused(.generationExhausted))
        let edit = DocumentInputTransaction(edit: fixture.edit,
            selection: try fixture.selection(2), typingIntent: fixture.intent)
        #expect(session.submit(.input(session.observation, edit)) ==
            .refused(.generationExhausted))
        #expect(session.state == .editable(exhausted))
    }
}
