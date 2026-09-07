import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("native Return splits a paragraph and backward deletion rejoins it")
    func returnAndJoin() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        let leading = window.session.document.content.blocks[0].blockID
        try window.key("\r", code: 36)
        try window.expect("A\nB", selection: NSRange(location: 2, length: 0))
        #expect(window.session.history.undo.count == 1)
        #expect(window.session.document.content.blocks[0].blockID == leading)
        window.view.deleteBackward(nil)
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
        #expect(window.session.history.undo.count == 2)
        #expect(window.session.document.content.blocks.count == 1)
        window.view.undoCanonicalEdit(nil)
        try window.expect("A\nB", selection: NSRange(location: 2, length: 0))
        window.view.redoCanonicalEdit(nil)
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
    }

    @Test("native multiline paste and spanning replacement each undo once")
    func multilinePasteAndReplace() throws
    {
        let window = try WritingTestWindow()
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        #expect(board.setString("One\r\nTwo\rThree", forType: .string))
        window.view.paste(board)
        let original = window.session.document
        try window.expect("One\nTwo\nThree", selection: NSRange(
            location: 13, length: 0
        ))
        #expect(window.session.history.undo.count == 1)
        window.select(2, 7)
        #expect(board.setString("X\n\nY", forType: .string))
        window.view.paste(board)
        try window.expect("OnX\n\nYhree", selection: NSRange(
            location: 6, length: 0
        ))
        #expect(window.session.history.undo.count == 2)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == original.content)
        try window.expect("One\nTwo\nThree", selection: NSRange(
            location: 2, length: 7
        ))
    }
}
