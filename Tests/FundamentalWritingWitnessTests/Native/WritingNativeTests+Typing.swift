import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func syntheticKeyPublishesOneCanonicalTransaction() throws
    {
        let window = try WritingTestWindow()
        defer
        {
            window.close()
        }
        try window.key("a", code: 0)
        try window.expect("a", selection: NSRange(location: 1, length: 0))
        #expect(window.session.history.undo.count == 1)
        #expect(window.session.state.snapshot.document.revision.value == 9)
        #expect(window.session.state.snapshot.generation.value == 4)
    }

    @Test(arguments: ["e\u{301}", "क\u{93F}", "👩🏽‍💻", "🇦🇲", "123 ± ∞"])
    func committedUnicodeKeepsExactSpelling(_ text: String) throws
    {
        let window = try WritingTestWindow()
        defer
        {
            window.close()
        }
        window.view.insertText(text, replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        try window.expect(text, selection: NSRange(
            location: text.utf16.count, length: 0
        ))
        #expect(window.session.history.undo.count == 1)
        #expect(window.session.state.snapshot.generation.value == 4)
    }

    @Test
    func selectedReplacementPublishesOnce() throws
    {
        let window = try WritingTestWindow("ABCD")
        defer
        {
            window.close()
        }
        window.select(1, 2)
        window.view.insertText("👋", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        try window.expect("A👋D", selection: NSRange(location: 3, length: 0))
        #expect(window.session.history.undo.count == 1)
        #expect(window.session.state.snapshot.document.revision.value == 9)
        #expect(window.session.state.snapshot.generation.value == 5)
    }

    @Test
    func privatePlainPastePublishesOneTransaction() throws
    {
        let window = try WritingTestWindow("AB")
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        window.select(1)
        #expect(board.setString("e\u{301}", forType: .string))
        window.view.paste(board)
        try window.expect("Ae\u{301}B", selection: NSRange(
            location: 3, length: 0
        ))
        #expect(window.session.history.undo.count == 1)
        #expect(window.session.state.snapshot.generation.value == 5)
    }
}
