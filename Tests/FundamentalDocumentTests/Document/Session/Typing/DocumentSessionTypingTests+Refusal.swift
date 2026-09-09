import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("stale and noncollapsed typing requests cannot change state")
    func refusal() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        let stale = session.observation
        let assignment = SemanticInlineTraitAssignment(trait: .strong,
                                                       enabled: true)
        session.submit(.typing(session.observation, assignment))
        let selected = DocumentSelection(
            range: try source.range((0, 0), (0, 2))
        )
        session.submit(.select(session.observation, selected))
        let before = session.current
        #expect(session.submit(.typing(stale, assignment)) ==
            .refused(.staleObservation))
        #expect(session.submit(.typing(session.observation, assignment)) ==
            .refused(.invalidCommand))
        #expect(session.current == before && !session.isDirty)
        let readable = DocumentSession(state: .readable(before.state.snapshot))
        let original = readable.current
        #expect(readable.submit(.typing(readable.observation, assignment)) ==
            .refused(.readOnly))
        #expect(readable.current == original)
    }

    @Test("a first explicit choice records intent even when appearance matches")
    func matchingInheritance() throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "A", traits: [.strong])
            ]))
        ])
        let session = DocumentSession(state: try source.state())
        let before = try Self.editable(session)
        #expect(before.typingIntent == nil)
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        let after = try Self.editable(session)
        #expect(after.typingIntent?.attributes == .direct(traits: [.strong]))
        #expect(after.snapshot.generation.value == 4)
        #expect(session.document == source.document && !session.canUndo)
    }
}
