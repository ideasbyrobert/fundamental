import Testing

@testable import FundamentalDocument

extension DocumentSessionScopeTypingTests
{
    @Test("scoped multiline code input retains programming-language spelling")
    func codeInput() throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            CodeConversionTestValue.code([SemanticRun(text: "AB")],
                                          language: " SwIfT ")
        ])
        let session = DocumentSession(state: try source.state())
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        for index in [0, 2]
        {
            session.submit(.typingScope(session.observation,
                try ScopeTestValue.assignments()[index]))
        }
        let expected = try ScopeTestValue.attributes(
            link: ScopeTestValue.newLink, language: ScopeTestValue.newLanguage,
            traits: [.strong]
        )
        try DocumentSessionTypingTests.insert("e\u{301}\r\n😀", into: session)
        CodeConversionTestValue.expectText(
            session.document, ["e\u{301}\r\n😀AB"]
        )
        #expect(try CodeConversionTestValue.runs(
            session.document.content.blocks[0]
        ) == [SemanticRun(text: "e\u{301}\r\n😀", attributes: expected),
              SemanticRun(text: "AB")])
        #expect(CodeConversionTestValue.language(session.document) == " SwIfT ")
        #expect(try DocumentSessionTypingTests.editable(session)
            .typingIntent?.attributes == expected)
    }
}
