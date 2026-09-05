import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingAcceptanceTests
{
    @Test
    func nativeHistoryStopsAtItsAdmittedEvictionFloor() throws
    {
        let seed = try #require(WritingDocumentSeed())
        let limits = try #require(DocumentHistoryLimits(
            transactions: 2, retainedUTF16Units: 16
        ))
        let session = DocumentSession(state: seed.state, historyLimits: limits)
        let window = try WritingTestWindow(session: session)
        defer
        {
            window.close()
        }
        for text in ["A", "BC", "D"]
        {
            window.view.insertText(text, replacementRange: NSRange(
                location: NSNotFound, length: 0
            ))
        }
        try window.expect("ABCD", selection: NSRange(location: 4, length: 0))
        #expect(session.history.undo.count == 2)
        #expect(session.history.retainedUTF16Units == 11)
        window.view.undoCanonicalEdit(nil)
        window.view.undoCanonicalEdit(nil)
        try window.expect("A", selection: NSRange(location: 1, length: 0))
        #expect(!session.canUndo)
        #expect(session.history.redo.count == 2)
        let floor = window.storage
        window.view.undoCanonicalEdit(nil)
        window.view.insertNewline(nil)
        #expect(window.storage == floor)
        window.view.redoCanonicalEdit(nil)
        window.view.redoCanonicalEdit(nil)
        try window.expect("ABCD", selection: NSRange(location: 4, length: 0))
        #expect(session.state.snapshot.document.revision.value == 7)
        #expect(session.state.snapshot.generation.value == 7)
    }

    @Test
    func nativeOversizedTransactionRefusesWithoutLosingRedo() throws
    {
        let seed = try #require(WritingDocumentSeed())
        let limits = try #require(DocumentHistoryLimits(
            transactions: 4, retainedUTF16Units: 3
        ))
        let session = DocumentSession(state: seed.state, historyLimits: limits)
        let window = try WritingTestWindow(session: session)
        defer
        {
            window.close()
        }
        window.view.insertText("A", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        window.view.undoCanonicalEdit(nil)
        let before = window.storage
        window.view.insertText("ABCD", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        #expect(window.storage == before)
        try window.expect("", selection: NSRange(location: 0, length: 0))
        window.view.redoCanonicalEdit(nil)
        try window.expect("A", selection: NSRange(location: 1, length: 0))
        #expect(session.state.snapshot.document.revision.value == 3)
        #expect(session.state.snapshot.generation.value == 3)
    }
}
