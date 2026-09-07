import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("saved window metadata follows typing and canonical undo")
    func fileMetadata() async throws
    {
        let fixture = try WritingFileFixture()
        let test = try WritingTestWindow("A")
        defer
        {
            test.close()
            fixture.remove()
        }
        let window = test.controller.documentWindow
        #expect(window.isDocumentEdited)
        try await test.controller.fileOwner.save(to: fixture.location)
        #expect(window.title == "Writing.fundamental")
        #expect(window.representedURL == fixture.location.url)
        #expect(!window.isDocumentEdited)
        test.select(1)
        test.view.insertText("B", replacementRange: test.view.selectedRange())
        #expect(window.isDocumentEdited)
        test.view.undoCanonicalEdit(nil)
        #expect(!window.isDocumentEdited)
        test.view.redoCanonicalEdit(nil)
        #expect(window.isDocumentEdited)
        try await test.controller.fileOwner.save(to: fixture.location)
        #expect(!window.isDocumentEdited)
        try test.expect("AB", selection: NSRange(location: 2, length: 0))
    }

    @Test("a verified clean document closes without a discard prompt")
    func cleanFileClose() async throws
    {
        let fixture = try WritingFileFixture()
        let test = try WritingTestWindow("Saved writing.")
        defer
        {
            test.close()
            fixture.remove()
        }
        #expect(!test.controller.mayClose())
        try await test.controller.fileOwner.save(to: fixture.location)
        #expect(test.controller.mayClose())
        #expect(!test.controller.discardApproved)
    }
}
