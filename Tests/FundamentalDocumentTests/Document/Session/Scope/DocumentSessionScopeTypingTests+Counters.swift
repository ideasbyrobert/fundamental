import Testing

@testable import FundamentalDocument

extension DocumentSessionScopeTypingTests
{
    @Test("scope typing uses generation while preserving revision and capacity")
    func counters() throws
    {
        let source = try SemanticWritingTestDocument([.body], revision: .max)
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        let assignment = try ScopeTestValue.assignments()[0]
        guard case .applied = session.submit(.typingScope(
            session.observation, assignment
        ))
        else
        {
            Issue.record("Expected scope typing at the final content revision")
            return
        }
        #expect(session.document == source.document && !session.isDirty)
        let state = try DocumentSessionTypingTests.editable(session)
        for intent in [nil, state.typingIntent]
        {
            let exhausted = try #require(EditableDocumentSnapshot(
                snapshot: DocumentSnapshot(generation: SnapshotGeneration(.max),
                                           document: source.document),
                selection: state.selection, typingIntent: intent
            ))
            let owner = DocumentSession(state: .editable(exhausted))
            let before = owner.current
            #expect(owner.submit(.typingScope(owner.observation, assignment)) ==
                (intent == nil ? .refused(.generationExhausted) : .unchanged))
            #expect(owner.current == before)
        }
    }

    @Test("scope intent does not consume text history capacity")
    func historyCapacity() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let limits = try #require(DocumentHistoryLimits(
            transactions: 1, retainedUTF16Units: 1
        ))
        let session = DocumentSession(state: try source.state(),
            historyLimits: limits, initiallySaved: true)
        guard case .applied = session.submit(.typingScope(
            session.observation, try ScopeTestValue.assignments()[2]
        ))
        else
        {
            Issue.record("Expected a scope choice without content history")
            return
        }
        let before = session.current
        #expect(try DocumentSessionTypingTests.insert("X", into: session) ==
            .refused(.historyCapacity))
        #expect(session.current == before && !session.isDirty)
    }
}
