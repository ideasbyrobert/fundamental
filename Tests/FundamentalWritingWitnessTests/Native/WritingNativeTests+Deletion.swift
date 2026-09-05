import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: ["A", "e\u{301}", "👋"])
    func backwardDeletionRemovesObservedNativeUnit(_ text: String) throws
    {
        let window = try WritingTestWindow(text)
        defer
        {
            window.close()
        }
        window.select(text.utf16.count)
        window.view.deleteBackward(nil)
        try window.expect("", selection: NSRange(location: 0, length: 0))
        #expect(window.session.history.undo.count == 1)
        #expect(window.session.state.snapshot.generation.value == 5)
    }

    @Test
    func devanagariDeletionAdmitsScalarInteriorProposal() throws
    {
        let window = try WritingTestWindow("क\u{93F}")
        defer
        {
            window.close()
        }
        window.select(2)
        window.view.deleteBackward(nil)
        try window.expect("क", selection: NSRange(location: 1, length: 0))
        #expect(window.session.history.undo.count == 1)
        #expect(window.session.state.snapshot.generation.value == 5)
    }

    @Test
    func forwardDeletionRemovesWholeSurrogatePair() throws
    {
        let window = try WritingTestWindow("👋B")
        defer
        {
            window.close()
        }
        window.view.deleteForward(nil)
        try window.expect("B", selection: NSRange(location: 0, length: 0))
        #expect(window.session.history.undo.count == 1)
        #expect(window.session.state.snapshot.generation.value == 4)
    }
}
