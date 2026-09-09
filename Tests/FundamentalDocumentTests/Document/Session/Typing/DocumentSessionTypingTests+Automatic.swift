import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("inherited formatting survives repeated empty paragraphs", arguments:
        [CanonicalBlockStyle.body, .numbered, .heading])
    func automaticReturn(style: CanonicalBlockStyle) throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            style.semanticBlock(runs: [
                SemanticRun(text: "A", traits: [.strong])
            ])
        ])
        let session = DocumentSession(state: try source.state(
            source.range((0, 1), (0, 1))
        ))
        #expect(try Self.editable(session).typingIntent == nil)
        try Self.returnAtCaret(in: session)
        try Self.returnAtCaret(in: session)
        let state = try Self.editable(session)
        #expect(state.typingIntent?.attributes == .direct(traits: [.strong]))
        let empty = try CodeConversionTestValue.runs(
            session.document.content.blocks[2]
        )
        #expect(empty.isEmpty)
        try Self.insert("B", into: session)
        CodeConversionTestValue.expectText(session.document, ["A", "", "B"])
        #expect(try CodeConversionTestValue.runs(
            session.document.content.blocks[2]
        ) == [SemanticRun(text: "B", traits: [.strong])])
    }

    @Test("ordinary typing keeps its implicit default representation")
    func implicitDefault() throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: [""])
        let session = DocumentSession(state: try source.state())
        try Self.insert("A", into: session)
        #expect(try Self.editable(session).typingIntent == nil)
        try Self.returnAtCaret(in: session)
        #expect(try Self.editable(session).typingIntent == nil)
        try Self.insert("B", into: session)
        #expect(try Self.editable(session).typingIntent == nil)
    }
}
