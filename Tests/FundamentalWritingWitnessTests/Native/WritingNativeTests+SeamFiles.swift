import AppKit
import FundamentalStorage
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true])
    func sourceEndingCRReopensWithItsNativeCodeEndpoint(tagged: Bool)
        async throws
    {
        let files = try WritingFileFixture()
        let fixture = try WritingCodeFixture.document("A", tagged: tagged)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
            files.remove()
        }
        window.select(8)
        window.commit("\r")
        let location = try #require(DocumentFileLocation(
            files.directory.appending(path: "SourceSeam.fun")
        ))
        try await window.controller.fileOwner.save(to: location)
        let owner = try await WritingFileOwner.open(location)
        let reopened = try WritingTestWindow(owner: owner)
        defer
        {
            reopened.close()
        }
        #expect(reopened.session.document == window.session.document)
        #expect(!reopened.session.isDirty)
        reopened.select(8)
        try reopened.key("\u{F703}", code: 124)
        try reopened.expect("Before\nA\r\r\nAfter", selection: NSRange(
            location: 9, length: 0
        ))
        try WritingWindowGeometry.expectVisibleCaret(reopened)
        try WritingCodeFixture.expect(
            reopened.session.document.content.blocks[1].block,
            text: "A\r", tagged: tagged
        )
    }
}
