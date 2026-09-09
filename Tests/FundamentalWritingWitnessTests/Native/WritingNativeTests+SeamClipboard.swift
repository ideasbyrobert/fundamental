import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true])
    func codeSeamChangesKeepSourceClipboardAndHistoryExact(tagged: Bool)
        throws
    {
        let fixture = try WritingCodeFixture.document("A\r", tagged: tagged)
        let original = fixture.state.snapshot.document.content
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        window.select(7, 2)
        window.view.copy(board)
        #expect(board.string(forType: .string)?.utf16.elementsEqual(
            "A\r".utf16
        ) == true)
        window.select(9)
        window.view.deleteBackward(nil)
        try window.expect("Before\nA\nAfter", selection: NSRange(
            location: 8, length: 0
        ))
        window.commit("\r")
        try window.expect("Before\nA\r\r\nAfter", selection: NSRange(
            location: 9, length: 0
        ))
        let span = window.controller.bridge.projection.map.spans[1]
        let font = NSFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        for offset in NSMaxRange(span.range) ..< NSMaxRange(span.range) + 2
        {
            #expect(window.view.textStorage?.attribute(
                .font, at: offset, effectiveRange: nil
            ) as? NSFont == font)
        }
        try window.key("\u{F703}", code: 124)
        #expect(window.view.selectedRange().location == 11)
        try window.key("\u{F702}", code: 123)
        #expect(window.view.selectedRange().location == 9)
        window.view.undoCanonicalEdit(nil)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == original)
        window.view.redoCanonicalEdit(nil)
        window.view.redoCanonicalEdit(nil)
        try WritingCodeFixture.expect(
            window.session.document.content.blocks[1].block,
            text: "A\r", tagged: tagged
        )
    }
}
