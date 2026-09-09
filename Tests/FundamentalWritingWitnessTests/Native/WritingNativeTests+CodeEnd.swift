import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true], [
        ("", "\n"), ("X\n", "\n"), ("X\r\n", "\r\n"),
        ("X\r", "\r"), ("A\r\nB\r", "\r")
    ])
    func codeOnlyDocumentTypesAtEmptyAndTrailingSourceLines(
        tagged: Bool, example: (source: String, newline: String)
    ) throws
    {
        let source = example.source
        let fixture = try WritingTestDocument(blocks: [
            WritingCodeFixture.block(source, tagged: tagged)
        ])
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        window.select(source.utf16.count)
        let font = window.view.typingAttributes[.font] as? NSFont
        #expect(font == NSFont.monospacedSystemFont(ofSize: 18,
                                                    weight: .regular))
        try window.key("\r", code: 36)
        window.commit("\te\u{301} 😀")
        let expected = source + example.newline + "\te\u{301} 😀"
        let blocks = window.session.document.content.blocks
        #expect(blocks.count == 1)
        #expect(blocks[0].blockID ==
            fixture.state.snapshot.document.content.blocks[0].blockID)
        try WritingCodeFixture.expect(blocks[0].block,
                                      text: expected, tagged: tagged)
        try window.expect(expected, selection: NSRange(
            location: expected.utf16.count, length: 0
        ))
        try WritingWindowGeometry.expectVisibleCaret(window)
        #expect(window.session.history.undo.count == 2)
        window.view.undoCanonicalEdit(nil)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            fixture.state.snapshot.document.content)
    }
}
