import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("deletion retains the caret intent at either edge", arguments:
        [0, 2], [true, false])
    func deletion(offset: Int, explicitlyPlain: Bool) throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "AB", traits: [.strong])
            ]))
        ])
        let range = try source.range((0, offset), (0, offset))
        let session = DocumentSession(state: try source.state(range))
        if explicitlyPlain
        {
            session.submit(.typing(session.observation,
                SemanticInlineTraitAssignment(trait: .strong, enabled: false)
            ))
        }
        let removal = try #require(SemanticTextDeletion(
            range: source.range((0, 0), (0, 2))
        ))
        session.submit(.edit(session.observation, .text(.deletion(removal))))
        let traits: Set<SemanticInlineTrait> = explicitlyPlain ? [] : [.strong]
        #expect(try Self.editable(session).typingIntent?.attributes ==
            .direct(traits: traits))
        CodeConversionTestValue.expectText(session.document, [""])
        try Self.insert("C", into: session)
        #expect(try CodeConversionTestValue.runs(
            session.document.content.blocks[0]
        ) == [SemanticRun(text: "C", traits: traits)])
    }
}
