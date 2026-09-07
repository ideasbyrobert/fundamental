import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("Cut finishes selected preedit before its separate deletion")
    func cutComposition() throws
    {
        let window = try WritingTestWindow("AB")
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        window.select(1)
        window.mark("漢字", selecting: NSRange(location: 0, length: 2))
        window.view.cut(board)
        #expect(board.string(forType: .string) == "漢字")
        #expect(!window.view.hasMarkedText())
        #expect(window.session.history.undo.count == 2)
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
        window.view.undoCanonicalEdit(nil)
        try window.expect("A漢字B", selection: NSRange(location: 1, length: 2))
        window.view.undoCanonicalEdit(nil)
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
    }

    @Test("a refused Cut retains the document and copied recovery text")
    func cutRefusal() throws
    {
        let limits = try #require(DocumentHistoryLimits(
            transactions: 1, retainedUTF16Units: 1
        ))
        let window = try WritingTestWindow(session: DocumentSession(
            state: WritingTestDocument("AB").state, historyLimits: limits,
            initiallySaved: true
        ))
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        window.select(0, 2)
        let before = window.storage
        window.view.cut(board)
        #expect(window.storage == before)
        #expect(!window.session.isDirty)
        #expect(board.string(forType: .string) == "AB")
        try window.expect("AB", selection: NSRange(location: 0, length: 2))
    }
}
