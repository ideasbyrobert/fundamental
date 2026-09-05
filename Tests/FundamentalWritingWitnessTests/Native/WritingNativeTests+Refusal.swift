import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: ["\n", "\r", "\r\n", "A\nB"])
    func nativeLineBreaksRefuseAtomically(_ text: String) throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        let before = window.storage
        window.view.insertText(text, replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        #expect(window.storage == before)
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
    }

    @Test
    func nativeReturnAndCapacityRefuseAtomically() throws
    {
        let text = String(repeating: "A", count: 65_536)
        let window = try WritingTestWindow(text)
        defer
        {
            window.close()
        }
        let before = window.storage
        window.view.insertNewline(nil)
        window.view.insertText("B", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        #expect(window.storage == before)
        try window.expect(text, selection: NSRange(location: 0, length: 0))
    }

    @Test
    func provisionalMarkedTextDoesNotEnterEitherAuthority() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        let before = window.storage
        window.view.setMarkedText(
            "か", selectedRange: NSRange(location: 1, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )
        #expect(!window.view.hasMarkedText())
        #expect(window.storage == before)
        try window.expect("AB", selection: NSRange(location: 0, length: 0))
        window.view.insertText("か", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        try window.expect("かAB", selection: NSRange(location: 1, length: 0))
        #expect(window.session.history.undo.count == 1)
    }
}
