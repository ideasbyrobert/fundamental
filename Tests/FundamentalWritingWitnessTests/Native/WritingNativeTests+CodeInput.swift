import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true])
    func codeReturnDeletionAndPasteKeepOneSourceBlock(tagged: Bool) throws
    {
        let fixture = try WritingCodeFixture.document("AB", tagged: tagged)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        window.select(8)
        try window.key("\r", code: 36)
        try window.expect("Before\nA\nB\nAfter", selection: NSRange(
            location: 9, length: 0
        ))
        let afterReturn = window.session.document.content
        #expect(afterReturn.blocks.count == 3)
        try WritingCodeFixture.expect(afterReturn.blocks[1].block,
                                      text: "A\nB", tagged: tagged)
        window.view.deleteBackward(nil)
        let deleted = window.session.document.content.blocks
        let original = fixture.state.snapshot.document.content.blocks
        #expect(deleted.map(\.blockID) == original.map(\.blockID))
        #expect(deleted.first == original.first &&
            deleted.last == original.last)
        try WritingCodeFixture.expect(deleted[1].block,
                                      text: "AB", tagged: tagged)
        try window.expect("Before\nAB\nAfter", selection: NSRange(
            location: 8, length: 0
        ))
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == afterReturn)
        window.view.redoCanonicalEdit(nil)
        let inserted = "\r\n\t\re\u{301} 😀\n\n"
        #expect(board.setString(inserted, forType: .string))
        window.view.paste(board)
        let text = "A" + inserted + "B"
        try window.expect("Before\n" + text + "\nAfter", selection: NSRange(
            location: 8 + inserted.utf16.count, length: 0
        ))
        try WritingCodeFixture.expect(
            window.session.document.content.blocks[1].block,
            text: text, tagged: tagged
        )
        #expect(window.session.history.undo.count == 3)
        window.select(7, text.utf16.count)
        window.commit("")
        try WritingCodeFixture.expect(
            window.session.document.content.blocks[1].block,
            text: "", tagged: tagged
        )
        try window.expect("Before\n\nAfter", selection: NSRange(
            location: 7, length: 0
        ))
        window.view.undoCanonicalEdit(nil)
        try window.expect("Before\n" + text + "\nAfter", selection: NSRange(
            location: 7, length: text.utf16.count
        ))
    }
}
