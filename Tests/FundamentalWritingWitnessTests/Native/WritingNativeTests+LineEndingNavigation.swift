import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: ["\r", "\n", "\r\n"])
    func codeLineEndingsNavigateAsWholeSourceCharacters(ending: String) throws
    {
        let fixture = try WritingCodeFixture.document("A" + ending + "B",
                                                     tagged: true)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        let before = window.session.document
        let start = 8
        let end = start + ending.utf16.count
        window.select(end)
        try window.key("\u{F702}", code: 123)
        #expect(window.view.selectedRange() == NSRange(
            location: start, length: 0
        ))
        try window.key("\u{F703}", code: 124)
        #expect(window.view.selectedRange() == NSRange(
            location: end, length: 0
        ))
        window.view.moveLeftAndModifySelection(nil)
        #expect(window.view.selectedRange() == NSRange(
            location: start, length: ending.utf16.count
        ))
        window.view.moveRightAndModifySelection(nil)
        #expect(window.view.selectedRange() == NSRange(
            location: end, length: 0
        ))
        #expect(window.session.document == before)
        #expect(window.session.history.undo.isEmpty)
    }
}
