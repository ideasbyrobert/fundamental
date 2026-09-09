import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true])
    func mixedCodeCompositionStaysProvisionalUntilOneCommit(code: Bool)
        throws
    {
        let first: CanonicalBlockStyle = code ? .monostyled : .title
        let last: CanonicalBlockStyle = code ? .body : .monostyled
        let window = try WritingTestWindow(styles: [first, last],
                                           texts: ["AB", "C\r\nD"])
        defer
        {
            window.close()
        }
        window.select(1, 3)
        let before = window.storage
        window.mark("題")
        window.mark("題名 e\u{301}😀")
        #expect(window.storage == before)
        #expect(window.view.hasMarkedText())
        try WritingWindowGeometry.expectVisibleCaret(window)
        window.view.cancelOperation(nil)
        #expect(window.storage == before)
        try window.expect("AB\nC\r\nD", selection: NSRange(
            location: 1, length: 3
        ))
        let inserted = "題名 e\u{301}😀"
        window.mark(inserted)
        window.commit(inserted)
        #expect(!window.view.hasMarkedText())
        #expect(window.styles == [first])
        #expect(window.session.history.undo.count == 1)
        try window.expect("A" + inserted + "\r\nD", selection: NSRange(
            location: 1 + inserted.utf16.count, length: 0
        ))
        let after = window.session.document.content
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == before.state.snapshot
            .document.content)
        window.view.redoCanonicalEdit(nil)
        #expect(window.session.document.content == after)
    }
}
