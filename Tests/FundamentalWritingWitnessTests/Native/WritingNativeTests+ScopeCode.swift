import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("scoped code preserves source lines and its separate language tag",
          arguments: [false, true])
    func nativeScopeCode(_ tagged: Bool) throws
    {
        let runs = [try WritingScopeFixture.run("AB\r\n", form: 2,
                                                traits: [.strong])]
        let tag = try #require(SemanticCodeLanguageIdentifier(" SwIfT "))
        let block: SemanticBlock = tagged
            ? .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs, language: tag)))
            : .code(.plain(PlainSemanticCodeBlock(runs: runs)))
        let source = try WritingTestDocument(blocks: [block], start: 1, end: 1)
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state
        ))
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        try window.key("\r", code: 36)
        let pasted = "e\u{301}😀\nX"
        #expect(board.setString(pasted, forType: .string))
        window.view.paste(board)
        let expected = "A\r\n" + pasted + "B\r\n"
        try window.expect(expected, selection: NSRange(
            location: 3 + pasted.utf16.count, length: 0
        ))
        let blocks = window.session.document.content.blocks
        #expect(blocks.count == 1)
        let code = try #require(EditableSemanticBlock(blocks[0].block))
        #expect(code.replacingRuns(runs) == block)
        #expect(code.runs.filter { !$0.text.isEmpty }.allSatisfy
            { $0.attributes == runs[0].attributes })
        WritingScopeFixture.expect(2, in: window.view.typingAttributes)
        let after = window.session.document.content
        #expect(window.session.history.undo.count == 2)
        window.view.undoCanonicalEdit(nil)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
        window.view.redoCanonicalEdit(nil)
        window.view.redoCanonicalEdit(nil)
        #expect(window.session.document.content == after)
    }
}
