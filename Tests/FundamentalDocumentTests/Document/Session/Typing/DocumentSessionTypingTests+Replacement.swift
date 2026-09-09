import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("backward replacement inherits selected scopes in source order")
    func replacement() throws
    {
        let scope = SemanticRunScopes.linkAndLanguage(
            link: try #require(SemanticLinkDestination("https://a.test/é")),
            language: try #require(SemanticLanguageIdentifier(" ru-RU "))
        )
        let attributes = SemanticRunAttributes.scoped(traits: [.strong],
                                                       scopes: scope)
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "A", attributes: attributes),
                SemanticRun(text: "e\u{301}😀", traits: [.emphasis])
            ]))
        ])
        let range = try source.range((0, 5), (0, 0))
        let session = DocumentSession(state: try source.state(range))
        let state = try Self.editable(session)
        #expect(state.typingAttributes(in: range) == attributes)
        let insertion = try #require(SemanticInsertion(text: "X",
                                                       attributes: attributes))
        let replacement = try #require(SemanticTextReplacement(
            range: source.range((0, 0), (0, 5)), insertion: insertion
        ))
        session.submit(.edit(session.observation, .text(.replacement(
            replacement
        ))))
        #expect(try CodeConversionTestValue.runs(
            session.document.content.blocks[0]
        ) == [SemanticRun(text: "X", attributes: attributes)])
        try Self.returnAtCaret(in: session)
        let intent = try Self.editable(session).typingIntent
        #expect(intent?.attributes == attributes)
        for _ in 0 ..< 2
        {
            session.submit(DocumentHistoryCommand(
                observation: session.observation, direction: .undo
            ))
        }
        let restored = try Self.editable(session).selection.range
        #expect(restored.start.utf16Offset == range.start.utf16Offset)
        #expect(restored.end.utf16Offset == range.end.utf16Offset)
        #expect(session.document.content == source.document.content)
    }
}
