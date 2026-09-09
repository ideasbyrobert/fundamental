import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("an edit elsewhere does not transfer the prior caret intent")
    func unrelatedEdit() throws
    {
        let source = try SemanticWritingTestDocument([.body, .body])
        let session = DocumentSession(state: try source.state())
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        let insertion = try #require(SemanticInsertion(
            text: "X", attributes: .direct(traits: [.emphasis])
        ))
        session.submit(.edit(session.observation, .text(.insertion(
            SemanticTextInsertion(point: try source.point(1, 0),
                                  insertion: insertion)
        ))))
        let state = try Self.editable(session)
        #expect(state.typingIntent == nil)
        #expect(state.typingAttributes(in: state.selection.range) ==
            .direct(traits: [.emphasis]))
        #expect(state.selection.range.start.blockID ==
            source.document.content.blocks[1].blockID)
        CodeConversionTestValue.expectText(session.document, ["ABCD", "XABCD"])
    }
}
