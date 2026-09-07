import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("paste accepts composition before its separate canonical insertion")
    func paste() throws
    {
        let window = try WritingTestWindow("AB")
        let pasteboard = NSPasteboard.withUniqueName()
        defer
        {
            window.close()
            pasteboard.releaseGlobally()
        }
        window.select(1)
        window.mark("é")
        #expect(pasteboard.setString("漢\n字", forType: .string))
        window.view.paste(pasteboard)
        try window.expect("Aé漢\n字B", selection: NSRange(location: 5, length: 0))
        #expect(window.session.history.undo.count == 2)
        window.view.undoCanonicalEdit(nil)
        try window.expect("AéB", selection: NSRange(location: 2, length: 0))
        window.view.undoCanonicalEdit(nil)
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
    }

    @Test("copy accepts and copies the selected preedit clause")
    func copy() throws
    {
        let window = try WritingTestWindow("AB")
        let pasteboard = NSPasteboard.withUniqueName()
        defer
        {
            window.close()
            pasteboard.releaseGlobally()
        }
        window.select(1)
        window.mark("漢字", selecting: NSRange(location: 0, length: 2))
        window.view.copy(pasteboard)
        #expect(pasteboard.string(forType: .string) == "漢字")
        #expect(!window.view.hasMarkedText())
        try window.expect("A漢字B", selection: NSRange(location: 1, length: 2))
        #expect(window.session.history.undo.count == 1)
    }
}
