import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("moving the selection clears intent while reassertion preserves it")
    func selectionLifetime() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let session = DocumentSession(state: try source.state())
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        let before = session.current
        let original = try Self.editable(session)
        #expect(session.submit(.select(session.observation,
                                        original.selection)) == .unchanged)
        #expect(session.current == before)
        session.submit(.select(session.observation, DocumentSelection(
            range: try source.range((0, 1), (0, 1))
        )))
        let moved = try Self.editable(session)
        #expect(moved.typingIntent == nil)
        #expect(moved.typingAttributes(in: moved.selection.range) ==
            .direct(traits: []))
        #expect(moved.snapshot.generation.value == 5)
        #expect(session.document == source.document && !session.canUndo)
    }

    @Test("explicit intent is confined to its own valid collapsed selection")
    func snapshotAdmission() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let range = try source.range((0, 0), (0, 0))
        let intent = DocumentTypingIntent(
            attributes: .direct(traits: [.strong])
        )
        let snapshot = DocumentSnapshot(generation: SnapshotGeneration(0),
                                        document: source.document)
        let state = try #require(EditableDocumentSnapshot(
            snapshot: snapshot, selection: DocumentSelection(range: range),
            typingIntent: intent
        ))
        #expect(state.typingAttributes(in: range) == intent.attributes)
        #expect(try state.typingAttributes(in: source.range((0, 1), (0, 1))) ==
            .direct(traits: []))
        #expect(try state.typingAttributes(in: source.range((0, 5), (0, 5))) ==
            nil)
        #expect(try EditableDocumentSnapshot(snapshot: snapshot,
            selection: DocumentSelection(range: source.range((0, 0), (0, 2))),
            typingIntent: intent
        ) == nil)
    }
}
