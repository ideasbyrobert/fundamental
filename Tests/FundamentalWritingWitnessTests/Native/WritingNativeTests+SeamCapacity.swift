import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func nativeSeamOverflowRefusesBeforePublishingSource() throws
    {
        let count = WritingSurfacePolicy.maximumUTF16Units - 2
        let source = String(repeating: "A", count: count)
        let fixture = try WritingTestDocument(blocks: [
            WritingCodeFixture.block(source, tagged: false),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "B")]))
        ])
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        window.select(count - 1, 1)
        let before = window.storage
        let dirty = window.session.isDirty
        window.commit("\r")
        #expect(window.storage == before)
        #expect(window.session.isDirty == dirty)
        try window.expect(source + "\nB", selection: NSRange(
            location: count - 1, length: 1
        ))
        #expect(window.controller.bridge.projection.map.utf16Count ==
            WritingSurfacePolicy.maximumUTF16Units)
    }
}
