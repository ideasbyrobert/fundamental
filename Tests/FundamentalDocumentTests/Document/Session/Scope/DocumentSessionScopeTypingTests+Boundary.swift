import Testing

@testable import FundamentalDocument

extension DocumentSessionScopeTypingTests
{
    @Test("ending a link keeps language and selection movement resets intent")
    func endingAtBoundary() throws
    {
        let original = try ScopeTestValue.attributes(
            link: ScopeTestValue.oldLink, language: ScopeTestValue.oldLanguage,
            traits: [.strong]
        )
        let ended = try ScopeTestValue.attributes(
            language: ScopeTestValue.oldLanguage, traits: [.strong]
        )
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "A", attributes: original),
                SemanticRun(text: "B", traits: [.emphasis])
            ]))
        ])
        let session = DocumentSession(state: try source.state(
            source.range((0, 1), (0, 1))
        ))
        session.submit(.typingScope(session.observation, .link(nil)))
        let state = try DocumentSessionTypingTests.editable(session)
        #expect(state.typingIntent?.attributes == ended)
        #expect(session.submit(.select(session.observation, state.selection)) ==
            .unchanged)
        try DocumentSessionTypingTests.insert("X", into: session)
        #expect(try CodeConversionTestValue.runs(
            session.document.content.blocks[0]
        ) == [SemanticRun(text: "A", attributes: original),
              SemanticRun(text: "X", attributes: ended),
              SemanticRun(text: "B", traits: [.emphasis])])
        let document = session.document
        let point = DocumentPoint(documentID: document.documentID,
            revision: document.revision,
            blockID: document.content.blocks[0].blockID,
            utf16Offset: try #require(DocumentUTF16Offset(0)))
        session.submit(.select(session.observation, .caret(at: point)))
        let moved = try DocumentSessionTypingTests.editable(session)
        #expect(moved.typingIntent == nil)
        #expect(moved.typingAttributes(in: moved.selection.range) == original)
    }
}
