import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [("A\r", "Z", "\n"), ("A", "\r", "\r\n")])
    func compositionCommitsAndCancelsAcrossCodeSeamChanges(
        example: (source: String, inserted: String, separator: String)
    ) throws
    {
        let fixture = try WritingCodeFixture.document(example.source,
                                                     tagged: true)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        let end = 7 + example.source.utf16.count
        window.select(end)
        let before = window.storage
        window.mark(example.inserted)
        #expect(window.view.hasMarkedText())
        #expect(window.storage == before)
        window.view.cancelOperation(nil)
        #expect(window.storage == before)
        window.mark(example.inserted)
        window.commit(example.inserted)
        #expect(!window.view.hasMarkedText())
        let source = example.source + example.inserted
        try window.expect("Before\n" + source + example.separator + "After",
                          selection: NSRange(location: end +
                            example.inserted.utf16.count, length: 0))
        try WritingCodeFixture.expect(
            window.session.document.content.blocks[1].block,
            text: source, tagged: true
        )
        #expect(window.session.history.undo.count == 1)
        try WritingWindowGeometry.expectVisibleCaret(window)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            fixture.state.snapshot.document.content)
    }
}
