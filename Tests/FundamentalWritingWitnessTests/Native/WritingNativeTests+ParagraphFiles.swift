import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("native multiline writing saves and reopens exact paragraphs")
    func paragraphFileRoundTrip() async throws
    {
        let fixture = try WritingFileFixture()
        let window = try WritingTestWindow()
        defer
        {
            window.close()
            fixture.remove()
        }
        let text = "First e\u{301} 😀\n\nSecond paragraph.\n"
        window.view.insertText(text, replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        try window.expect(text, selection: NSRange(
            location: text.utf16.count, length: 0
        ))
        try await window.controller.fileOwner.save(to: fixture.location)
        let owner = try await WritingFileOwner.open(fixture.location)
        #expect(owner.session.document == window.session.document)
        #expect(owner.session.document.content.blocks.count == 4)
        #expect(!owner.session.isDirty)
        let reopened = try WritingTestWindow(owner: owner)
        defer
        {
            reopened.close()
        }
        try reopened.expect(text, selection: NSRange(location: 0, length: 0))
        #expect(!reopened.controller.documentWindow.isDocumentEdited)
    }
}
