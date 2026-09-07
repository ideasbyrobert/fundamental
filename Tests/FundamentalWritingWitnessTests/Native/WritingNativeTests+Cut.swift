import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("Cut preserves exact Unicode and paragraph history",
          arguments: ["e\u{301}👩‍👩‍👧‍👦", "One\n\nTwo", "漢字\n👋"])
    func cutAndRestore(_ selected: String) throws
    {
        let window = try WritingTestWindow()
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        let original = "A" + selected + "B"
        window.view.insertText(original, replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        window.select(1, selected.utf16.count)
        let content = window.session.document.content
        let count = window.session.history.undo.count
        window.view.cut(board)
        let copied = try #require(board.string(forType: .string))
        #expect(copied.utf16.elementsEqual(selected.utf16))
        #expect(window.session.history.undo.count == count + 1)
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == content)
        try window.expect(original, selection: NSRange(
            location: 1, length: selected.utf16.count
        ))
        window.view.redoCanonicalEdit(nil)
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
    }

    @Test("Cut with no selection preserves content and clipboard")
    func cutEmptySelection() throws
    {
        let window = try WritingTestWindow("AB")
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        #expect(board.setString("Existing clipboard", forType: .string))
        window.select(1)
        let before = window.storage
        window.view.cut(board)
        #expect(window.storage == before)
        #expect(board.string(forType: .string) == "Existing clipboard")
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
    }
}
