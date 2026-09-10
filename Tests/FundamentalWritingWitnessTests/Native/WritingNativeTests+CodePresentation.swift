import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true])
    func codeUsesNativeMonospacedTypeAndTruthfulFormatting(tagged: Bool)
        throws
    {
        let fixture = try WritingCodeFixture.document(
            WritingCodeFixture.text, tagged: tagged
        )
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        let spans = window.controller.bridge.projection.map.spans
        let storage = try #require(window.view.textStorage)
        for (index, span) in spans.enumerated()
        {
            let font = try #require(storage.attribute(.font,
                at: span.range.location, effectiveRange: nil) as? NSFont)
            #expect(font.pointSize == (index == 1 ? 18 : 20))
            if index == 1
            {
                #expect(font == NSFont.monospacedSystemFont(
                    ofSize: 18, weight: .regular
                ))
            }
        }
        window.select(7)
        let formatting = window.controller.formatting
        #expect(formatting.block.selectedItem?.title == "Code")
        #expect(formatting.block.isEnabled && formatting.list.isEnabled)
        #expect(window.controller.canFormatSelection)
        let heading = try window.formatChoice("Heading 4",
                                               group: "Paragraph Style")
        #expect(window.controller.validateUserInterfaceItem(heading))
        window.select(0, NSMaxRange(spans[1].range))
        #expect(formatting.block.isEnabled && formatting.list.isEnabled)
        window.select(spans[2].range.location)
        #expect(formatting.block.isEnabled && formatting.list.isEnabled)
        #expect(formatting.block.selectedItem?.title == "Body")
        window.commit("Edited ")
        try WritingCodeFixture.expect(
            window.session.document.content.blocks[1].block,
            text: WritingCodeFixture.text, tagged: tagged
        )
        #expect(window.view.string.hasSuffix("Edited After"))
    }

    @Test(arguments: [false, true])
    func codeCaretRemainsVisibleAcrossSourceLinesAndResize(tagged: Bool)
        throws
    {
        let source = String(repeating: "\tlet value = \"e\u{301} 😀\"\r\n",
                            count: 120)
        let fixture = try WritingCodeFixture.document(source, tagged: tagged)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        for offset in [7, 7 + source.utf16.count / 2, 7 + source.utf16.count]
        {
            window.select(offset)
            window.view.scrollRangeToVisible(window.view.selectedRange())
            try WritingWindowGeometry.expectVisibleCaret(window)
        }
        window.controller.documentWindow.setContentSize(NSSize(
            width: 480, height: 420
        ))
        try WritingWindowGeometry.expectVisibleCaret(window)
        #expect(window.session.document.content ==
            fixture.state.snapshot.document.content)
    }
}
