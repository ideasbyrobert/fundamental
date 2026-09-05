import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingAcceptanceTests
{
    @Test
    func longCommittedInputKeepsTheCanonicalCaretOnGlass() throws
    {
        let seed = try #require(WritingDocumentSeed())
        let window = try WritingTestWindow(session: DocumentSession(
            state: seed.state
        ))
        defer
        {
            window.close()
        }
        let text = String(repeating: "A readable sentence. ", count: 500)
        window.view.insertText(text, replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        let caret = NSRange(location: text.utf16.count, length: 0)
        try window.expect(text, selection: caret)
        try WritingWindowGeometry.expectVisibleCaret(window)
        #expect(window.controller.scrollView.documentVisibleRect.origin.y > 0)
        #expect(window.view.textLayoutManager != nil)
        #expect(window.session.history.undo.count == 1)
        window.view.undoCanonicalEdit(nil)
        try window.expect("", selection: NSRange(location: 0, length: 0))
        try WritingWindowGeometry.expectVisibleCaret(window)
        window.view.redoCanonicalEdit(nil)
        try window.expect(text, selection: caret)
        try WritingWindowGeometry.expectVisibleCaret(window)
        #expect(window.session.state.snapshot.document.revision.value == 3)
        #expect(window.session.state.snapshot.generation.value == 3)
    }
}
