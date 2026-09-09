import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func codeMenuConversionPreservesSelectionAndCanonicalHistory() throws
    {
        let window = try WritingTestWindow(styles: [.title, .numbered],
                                            texts: ["A", "B"])
        defer
        {
            window.close()
        }
        window.select(0, 3)
        let original = window.session.document.content
        let code = try window.formatChoice("Code", group: "Paragraph Style")
        #expect(window.controller.validateUserInterfaceItem(code))
        try window.performFormat(code)
        try window.expect("A\nB", selection: NSRange(location: 0, length: 3))
        #expect(window.session.document.content.blocks.count == 1)
        try WritingCodeFixture.expect(window.session.document.content
            .blocks[0].block, text: "A\nB", tagged: false)
        #expect(window.session.history.undo.count == 1)
        let beforeRemoval = window.storage
        try window.performFormat(window.formatChoice("No List", group: "List"))
        #expect(window.storage == beforeRemoval)
        try window.performFormat(window.formatChoice("Numbered", group: "List"))
        #expect(window.styles == [.numbered, .numbered])
        #expect(window.session.history.undo.count == 2)
        try window.expect("A\nB", selection: NSRange(location: 0, length: 3))
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content.blocks.count == 1)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == original)
        try WritingWindowGeometry.expectVisibleCaret(window)
    }

    @Test
    func codeMenuSplittingKeepsTheFinalEmptyLineReachable() throws
    {
        let source = "A\r\nB\r"
        let fixture = try WritingCodeFixture.document(source, tagged: true)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        window.select(7 + source.utf16.count)
        let heading = try window.formatChoice("Heading",
                                               group: "Paragraph Style")
        try window.performFormat(heading)
        try window.expect("Before\nA\nB\n\nAfter",
                          selection: NSRange(location: 11, length: 0))
        #expect(window.styles == [.body, .heading, .heading, .heading, .body])
        try WritingWindowGeometry.expectVisibleCaret(window)
        window.view.undoCanonicalEdit(nil)
        try window.expect("Before\n" + source + "\r\nAfter",
            selection: NSRange(location: 7 + source.utf16.count, length: 0))
        try WritingCodeFixture.expect(window.session.document.content
            .blocks[1].block, text: source, tagged: true)
        try WritingWindowGeometry.expectVisibleCaret(window)
    }
}
