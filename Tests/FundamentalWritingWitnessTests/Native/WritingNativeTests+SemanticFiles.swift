import AppKit
import FundamentalStorage
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("fun and legacy files reopen the exact complete semantic document")
    func semanticFiles() async throws
    {
        let fixture = try WritingFileFixture()
        let styles: [CanonicalBlockStyle] = [
            .title, .heading, .body, .bulleted, .numbered, .numbered
        ]
        let window = try WritingTestWindow(styles: styles, texts: [
            "A title", "A heading", "A paragraph e\u{301} 😀", "A bullet",
            "First item", "Second item"
        ])
        defer
        {
            window.close()
            fixture.remove()
        }
        for name in ["Semantic.fun", "Legacy.fundamental"]
        {
            let location = try #require(DocumentFileLocation(
                fixture.directory.appending(path: name)
            ))
            try await window.controller.fileOwner.save(to: location)
            #expect(!window.session.isDirty)
            let owner = try await WritingFileOwner.open(location)
            #expect(owner.session.document == window.session.document)
            let reopened = try WritingTestWindow(owner: owner)
            defer
            {
                reopened.close()
            }
            #expect(reopened.styles == styles.map(Optional.some))
            #expect(try reopened.markerLabels() == ["•", "1.", "2."])
            #expect(reopened.view.string.utf16.elementsEqual(
                window.view.string.utf16
            ))
            #expect(reopened.controller.documentWindow.representedURL ==
                location.url)
        }
    }
}
