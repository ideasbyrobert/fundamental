import Testing

@testable import FundamentalDocument

extension DocumentTextBatchTests
{
    @Test("replacements retain untouched runs, scopes, lists and code tags")
    func preservedMeaning() throws
    {
        let scoped = try ScopeTestValue.attributes(
            link: "https://example.test/words", language: "ru"
        )
        let prefix = SemanticRun(text: "Before", traits: [.strong])
        let tail = SemanticRun(text: " tail", attributes: scoped)
        let empty = SemanticRun(text: "", traits: [.underline])
        let runs = [prefix, SemanticRun(text: "e", attributes: scoped),
                    empty, SemanticRun(text: "\u{301}", traits: [.emphasis]),
                    tail, empty]
        let code = try CodeConversionTestValue.code([
            SemanticRun(text: "A\r\nB\r\n")
        ], language: " SwIfT ")
        let source = try SemanticWritingTestDocument(blocks: [
            .listItem(SemanticListItem(kind: .numbered, runs: runs)), code,
            CanonicalBlockStyle.heading.semanticBlock(runs: [
                SemanticRun(text: "Untouched 🇦🇲")
            ])
        ])
        let listRange = try source.range((0, 6), (0, 8))
        let codeRange = try source.range((1, 3), (1, 4))
        let first = try #require(SemanticTextSubstitution(
            range: listRange, text: "Ё", attributes: scoped
        ))
        let second = try #require(SemanticTextSubstitution(
            range: codeRange, text: "C\nD", attributes: .direct(traits: [])
        ))
        let batch = try #require(SemanticTextBatchReplacement([second, first]))
        let session = DocumentSession(state: try source.state())
        session.submit(.replace(session.observation, batch))
        let blocks = session.document.content.blocks
        #expect(blocks.map(\.blockID) == source.document.content.blocks
            .map(\.blockID))
        #expect(blocks[0].block == .listItem(SemanticListItem(
            kind: .numbered, runs: [prefix,
                SemanticRun(text: "Ё", attributes: scoped), tail, empty]
        )))
        let expectedCode = try CodeConversionTestValue.code([
            SemanticRun(text: "A\r\n"), SemanticRun(text: "C\nD"),
            SemanticRun(text: "\r\n")
        ], language: " SwIfT ")
        #expect(blocks[1].block == expectedCode)
        #expect(blocks[2] == source.document.content.blocks[2])
        #expect(session.history.undo.count == 1)
        try Self.move(session, .undo)
        #expect(session.document.content == source.document.content)
    }

    @Test("a deletion that joins graphemes resolves a valid final caret")
    func joinedCaret() throws
    {
        let fixture = try SessionTestDocument(texts: ["e\n\u{301}"])
        let batch = try Self.batch([(0, 1 ..< 2, "")], in: fixture)
        let session = DocumentSession(state: fixture.state)
        guard case let .applied(.editable(after)) = session.submit(
            .replace(fixture.observation, batch)
        )
        else
        {
            Issue.record("Expected joined text with a valid caret")
            return
        }
        #expect(try Self.spelling(session) == [Array("e\u{301}".utf16)])
        #expect(after.selection.range.start.utf16Offset.value == 2)
    }
}
