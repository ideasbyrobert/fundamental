import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true])
    func sourceEndingCRRemainsEditableBeforeAnotherBlock(tagged: Bool) throws
    {
        let fixture = try WritingCodeFixture.document("A\r", tagged: tagged)
        let original = fixture.state.snapshot.document.content
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        let end = 9
        window.select(end - 1)
        try window.key("\u{F703}", code: 124)
        #expect(window.view.selectedRange() == NSRange(
            location: end, length: 0
        ))
        try WritingWindowGeometry.expectVisibleCaret(window)
        var actual = NSRange(location: NSNotFound, length: 0)
        let caret = window.view.firstRect(forCharacterRange: NSRange(
            location: end, length: 0
        ), actualRange: &actual)
        #expect(actual.location == end)
        let next = try #require(window.controller.bridge.projection.map
            .spans.last)
        let prose = window.view.firstRect(forCharacterRange: NSRange(
            location: next.range.location, length: 0
        ), actualRange: nil)
        #expect(abs(caret.midY - prose.midY) > 1)
        try window.key("Z", code: 6)
        let blocks = window.session.document.content.blocks
        #expect(blocks.map(\.blockID) == original.blocks.map(\.blockID))
        #expect(blocks.first == original.blocks.first)
        #expect(blocks.last == original.blocks.last)
        try WritingCodeFixture.expect(blocks[1].block,
                                      text: "A\rZ", tagged: tagged)
        try window.expect("Before\nA\rZ\nAfter", selection: NSRange(
            location: end + 1, length: 0
        ))
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == original)
        try window.expect("Before\nA\r\r\nAfter", selection: NSRange(
            location: end, length: 0
        ))
        try WritingWindowGeometry.expectVisibleCaret(window)
    }
}
