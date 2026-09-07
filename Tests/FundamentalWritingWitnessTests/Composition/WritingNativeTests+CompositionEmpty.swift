import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("empty preedit ends without deleting unselected canonical content")
    func empty() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        let before = window.storage
        window.mark("draft")
        window.mark("")
        #expect(window.storage == before)
        #expect(!window.view.hasMarkedText())
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
    }

    @Test("accepting an empty replacement deletes the original selected text")
    func emptyReplacement() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(0, 1)
        window.mark("draft")
        window.commit("")
        #expect(window.session.history.undo.count == 1)
        try window.expect("B", selection: NSRange(location: 0, length: 0))
        window.view.undoCanonicalEdit(nil)
        try window.expect("AB", selection: NSRange(location: 0, length: 1))
    }
}
