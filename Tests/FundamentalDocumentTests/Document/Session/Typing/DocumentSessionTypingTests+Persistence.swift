import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("typing choices stay outside saved content and fresh session state")
    func persistence() throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: [""])
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        let original = try codec.encode(session.document)
        let pending = session.prepareSave()
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        #expect(try codec.encode(session.document) == original)
        #expect(session.acknowledgeSave(pending) && !session.isDirty)
        let reopened = try codec.decode(original)
        let point = try source.point(0, 0)
        let fresh = try #require(EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(generation: SnapshotGeneration(0),
                                       document: reopened),
            selection: .caret(at: point)
        ))
        #expect(fresh.typingIntent == nil)
        #expect(fresh.typingAttributes(in: fresh.selection.range) ==
            .direct(traits: []))
        try Self.insert("e\u{301}😀", into: session)
        let bytes = try codec.encode(session.document)
        #expect(bytes != original && session.isDirty)
        let decoded = try codec.decode(bytes)
        CodeConversionTestValue.expectText(decoded, ["e\u{301}😀"])
        #expect(try CodeConversionTestValue.runs(decoded.content.blocks[0]) == [
            SemanticRun(text: "e\u{301}😀", traits: [.strong]),
            SemanticRun(text: "")
        ])
    }
}
