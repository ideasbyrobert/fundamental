import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true], [false, true])
    func deletingCodeBoundaryKeepsUntouchedSource(
        tagged: Bool, backward: Bool
    ) throws
    {
        let source = "A\r\n\te\u{301}😀\r"
        let fixture = try WritingCodeFixture.document(source, tagged: tagged)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        window.select(backward ? 7 : 6)
        if backward
        {
            window.view.deleteBackward(nil)
        }
        else
        {
            window.view.deleteForward(nil)
        }
        try window.expect("Before" + source + "\r\nAfter",
            selection: NSRange(location: 6, length: 0))
        #expect(window.styles == [.body, .body])
        #expect(window.session.history.undo.count == 1)
        let first = try #require(EditableSemanticBlock(
            window.session.document.content.blocks[0].block
        ))
        #expect(first.runs.map(\.text).joined().utf16.elementsEqual(
            ("Before" + source).utf16
        ))
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            fixture.state.snapshot.document.content)
        try window.expect("Before\n" + source + "\r\nAfter",
            selection: NSRange(location: backward ? 7 : 6, length: 0))
    }
}
