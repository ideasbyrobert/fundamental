import AppKit
import FundamentalStorage
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true])
    func codeFilesReopenExactSourceAndLanguage(tagged: Bool) async throws
    {
        let files = try WritingFileFixture()
        let fixture = try WritingCodeFixture.document(
            WritingCodeFixture.text, tagged: tagged
        )
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
            files.remove()
        }
        window.select(7)
        window.commit("\t\r\n")
        for name in ["Code.fun", "Code.fundamental"]
        {
            let location = try #require(DocumentFileLocation(
                files.directory.appending(path: name)
            ))
            try await window.controller.fileOwner.save(to: location)
            let owner = try await WritingFileOwner.open(location)
            #expect(owner.session.document == window.session.document)
            let reopened = try WritingTestWindow(owner: owner)
            defer
            {
                reopened.close()
            }
            try WritingCodeFixture.expect(
                reopened.session.document.content.blocks[1].block,
                text: "\t\r\n" + WritingCodeFixture.text, tagged: tagged
            )
            #expect(reopened.view.string.utf16.elementsEqual(
                window.view.string.utf16
            ))
            #expect(!reopened.session.isDirty)
        }
    }
}
