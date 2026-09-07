import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    @MainActor
    @Test("paragraph replacement uses one session transaction and saved origin")
    func singleHistoryTransaction() throws
    {
        let source = try SessionTestDocument(texts: ["AB", "CD", "EF"])
        let edit = try request(
            in: source, from: (0, 1), to: (2, 1), text: ["X", "Y"]
        )
        let session = DocumentSession(state: source.state, initiallySaved: true)
        session.submit(.edit(source.observation, .paragraphs(edit)))
        #expect(session.history.undo.count == 1)
        #expect(session.state.snapshot.generation.value == 4)
        #expect(session.document.revision.value == 9)
        #expect(session.isDirty)
        let after = session.document
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        #expect(session.document.content == source.editable.snapshot
            .document.content)
        #expect(!session.isDirty)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        #expect(session.document.content == after.content)
        #expect(session.isDirty)
        #expect(session.acknowledgeSave(session.prepareSave()))
        #expect(!session.isDirty)
    }

    @MainActor
    @Test("an invalid paragraph endpoint leaves the complete session untouched")
    func invalidEndpoint() throws
    {
        let source = try SessionTestDocument(texts: ["😀", "e\u{301}"])
        let session = DocumentSession(state: source.state, initiallySaved: true)
        for endpoints in [((0, 1), (1, 0)), ((0, 2), (1, 1))]
        {
            let edit = try request(
                in: source, from: endpoints.0, to: endpoints.1, text: ["X"]
            )
            let before = DocumentSessionStorage(
                state: session.state, history: session.history
            )
            #expect(session.submit(.edit(source.observation, .paragraphs(edit)))
                == .refused(.invalidCommand))
            #expect(before == DocumentSessionStorage(
                state: session.state, history: session.history
            ))
            #expect(!session.isDirty)
        }
    }
}
