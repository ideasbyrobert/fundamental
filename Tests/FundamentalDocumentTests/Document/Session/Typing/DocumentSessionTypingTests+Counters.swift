import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("typing state consumes generation without consuming content revision")
    func counters() throws
    {
        let source = try SemanticWritingTestDocument([.body], revision: .max)
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        let assignment = SemanticInlineTraitAssignment(trait: .strong,
                                                       enabled: true)
        guard case .applied = session.submit(.typing(session.observation,
                                                     assignment))
        else
        {
            Issue.record("Expected typing intent at the final content revision")
            return
        }
        #expect(session.document == source.document && !session.isDirty)
        let state = try Self.editable(session)
        for intent in [nil, state.typingIntent]
        {
            let exhausted = try #require(EditableDocumentSnapshot(
                snapshot: DocumentSnapshot(generation: SnapshotGeneration(.max),
                                           document: source.document),
                selection: state.selection, typingIntent: intent
            ))
            let session = DocumentSession(state: .editable(exhausted))
            let before = session.current
            #expect(session.submit(.typing(session.observation, assignment)) ==
                (intent == nil ? .refused(.generationExhausted) : .unchanged))
            #expect(session.current == before)
        }
    }

    @Test("text history capacity does not block a typing choice")
    func historyCapacity() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let limits = try #require(DocumentHistoryLimits(transactions: 1,
                                                        retainedUTF16Units: 1))
        let session = DocumentSession(
            state: try source.state(), historyLimits: limits,
            initiallySaved: true
        )
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        #expect(try Self.editable(session).typingIntent != nil)
        let before = session.current
        let result = try Self.insert("X", into: session)
        #expect(result == .refused(.historyCapacity))
        #expect(session.current == before && !session.isDirty)
    }
}
