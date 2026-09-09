import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true])
    func codeReturnFinishesCompositionBeforeChoosingItsLineEnding(tagged: Bool)
        throws
    {
        let fixture = try WritingCodeFixture.document("X\r\n", tagged: tagged)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        window.select(7)
        window.mark("e\u{301}")
        window.view.insertNewline(nil)
        #expect(!window.view.hasMarkedText())
        #expect(window.session.history.undo.count == 2)
        try window.expect("Before\ne\u{301}\r\nX\r\n\nAfter",
                          selection: NSRange(location: 11, length: 0))
        try WritingCodeFixture.expect(
            window.session.document.content.blocks[1].block,
            text: "e\u{301}\r\nX\r\n", tagged: tagged
        )
        window.view.undoCanonicalEdit(nil)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            fixture.state.snapshot.document.content)
    }

    @Test(arguments: [false, true])
    func codeCompositionPreservesSourceAndOneHistoryEntry(tagged: Bool)
        throws
    {
        let fixture = try WritingCodeFixture.document("", tagged: tagged)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        window.select(7)
        let before = window.storage
        let source = "\t題名\r\ne\u{301} 😀\n"
        window.mark(source)
        #expect(window.view.hasMarkedText())
        #expect(window.storage == before)
        #expect(window.view.string.utf16.elementsEqual(
            ("Before\n" + source + "\nAfter").utf16
        ))
        try WritingWindowGeometry.expectVisibleCaret(window)
        window.view.cancelOperation(nil)
        #expect(window.storage == before)
        try window.expect("Before\n\nAfter", selection: NSRange(
            location: 7, length: 0
        ))
        window.mark(source)
        window.commit(source)
        #expect(!window.view.hasMarkedText())
        #expect(window.session.history.undo.count == 1)
        try WritingCodeFixture.expect(
            window.session.document.content.blocks[1].block,
            text: source, tagged: tagged
        )
        try window.expect("Before\n" + source + "\nAfter", selection: NSRange(
            location: 7 + source.utf16.count, length: 0
        ))
        try WritingWindowGeometry.expectVisibleCaret(window)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            fixture.state.snapshot.document.content)
        window.view.redoCanonicalEdit(nil)
        try WritingCodeFixture.expect(
            window.session.document.content.blocks[1].block,
            text: source, tagged: tagged
        )
    }
}
