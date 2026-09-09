import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("a grapheme join retains the inserted scope spelling")
    func scopeSpelling() throws
    {
        let composed = try #require(SemanticLinkDestination("https://a.test/é"))
        let decomposed = try #require(SemanticLinkDestination(
            "https://a.test/e\u{301}"
        ))
        let incoming = SemanticRunAttributes.scoped(traits: [],
                                                     scopes: .link(decomposed))
        let following = SemanticRunAttributes.scoped(traits: [],
                                                      scopes: .link(composed))
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "\u{301}", attributes: following)
            ]))
        ])
        let session = DocumentSession(state: try source.state())
        let insertion = try #require(SemanticInsertion(text: "e",
                                                       attributes: incoming))
        session.submit(.edit(session.observation, .text(.insertion(
            SemanticTextInsertion(point: try source.point(0, 0),
                                  insertion: insertion)
        ))))
        let state = try Self.editable(session)
        #expect(state.selection.range.start.utf16Offset.value == 2)
        #expect(state.typingIntent != nil)
        guard case let .scoped(_, .link(link)) =
            state.typingAttributes(in: state.selection.range)
        else
        {
            Issue.record("Expected the preserved link context")
            return
        }
        #expect(link.value.utf16.elementsEqual(decomposed.value.utf16))
        CodeConversionTestValue.expectText(session.document, ["e\u{301}"])
    }
}
