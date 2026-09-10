import Testing

@testable import FundamentalDocument

extension DocumentSessionScopeTypingTests
{
    @Test("stale read-only and nonempty selections cannot choose typing scopes")
    func refusal() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let assignment = try ScopeTestValue.assignments()[0]
        let readable = DocumentSession(state: .readable(DocumentSnapshot(
            generation: SnapshotGeneration(0), document: source.document
        )))
        let untouched = readable.current
        #expect(readable.submit(.typingScope(
            readable.observation, assignment
        )) == .refused(.readOnly))
        #expect(readable.current == untouched)
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        let stale = session.observation
        session.submit(.select(session.observation, DocumentSelection(
            range: try source.range((0, 0), (0, 2))
        )))
        let before = session.current
        #expect(session.submit(.typingScope(stale, assignment)) ==
            .refused(.staleObservation))
        #expect(session.submit(.typingScope(session.observation, assignment)) ==
            .refused(.invalidCommand))
        #expect(session.current == before && !session.isDirty)
    }

    @Test("scope typing preserves redo and history restores its own intent")
    func redo() throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: ["A"])
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        try DocumentSessionTypingTests.insert("X", into: session)
        let changed = session.document.content
        let priorIntent = try DocumentSessionTypingTests.editable(session)
            .typingIntent
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        let history = session.history
        session.submit(.typingScope(session.observation,
            try ScopeTestValue.assignments()[0]))
        #expect(session.history == history && session.canRedo)
        #expect(session.document.content == source.document.content)
        #expect(!session.isDirty)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        #expect(session.document.content == changed)
        let restored = try DocumentSessionTypingTests.editable(session)
        #expect(restored.typingIntent == priorIntent)
        #expect(restored.typingAttributes(in: restored.selection.range) ==
            .direct(traits: []))
    }
}
