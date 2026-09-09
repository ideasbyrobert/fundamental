import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func codeMenuRefusesExcessParagraphsBeforePublishing() throws
    {
        let source = String(repeating: "\n",
                            count: WritingSurfacePolicy.maximumParagraphs)
        let fixture = try WritingTestDocument(blocks: [
            WritingCodeFixture.block(source, tagged: false)
        ])
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let original = window.storage
        try window.performFormat(window.formatChoice("Body",
                                                      group: "Paragraph Style"))
        #expect(window.storage == original)
        #expect(!window.session.isDirty)
        try window.expect(source, selection: NSRange(location: 0, length: 0))
        #expect(window.controller.formatting.block.selectedItem?.title ==
            "Code")
    }
}
