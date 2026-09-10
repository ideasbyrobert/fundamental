import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("all direct trait combinations retain every non-table block role")
    func nativeInlineCombinations() throws
    {
        for bits in 0 ..< (1 << WritingInlineFixture.traits.count)
        {
            let traits = Set(WritingInlineFixture.traits.enumerated().compactMap
                { index, trait in bits & (1 << index) == 0 ? nil : trait })
            let runs = [SemanticRun(text: "Ae\u{301}😀Z", traits: traits)]
            let blocks = try WritingInlineFixture.roles(runs)
            let fixture = try WritingTestDocument(blocks: blocks)
            let projection = try fixture.projection()
            let presentation = try #require(WritingTextPresentation(projection))
            #expect(presentation.text.string.utf16.elementsEqual(
                projection.text.utf16
            ))
            var ordinal = 0
            for (index, block) in blocks.enumerated()
            {
                let base = try #require(WritingTypography.attributes(
                    for: block, ordinal: &ordinal
                )?[.font] as? NSFont)
                let attributes = presentation.text.attributes(
                    at: projection.map.spans[index].range.location,
                    effectiveRange: nil
                )
                try WritingInlineFixture.expect(traits, in: attributes,
                                                 base: base)
            }
            #expect(projection.snapshot.snapshot.document ==
                fixture.state.snapshot.document)
        }
    }

    @Test("all seven inline traits draw with visible native caret geometry",
          arguments: [NSAppearance.Name.aqua, .darkAqua])
    func nativeInlineDrawing(_ appearance: NSAppearance.Name) throws
    {
        let words = ["Strong", "Emphasis", "Underline", "Strikethrough",
                     "Inline code", "Superscript", "Subscript"]
        let blocks = zip(WritingInlineFixture.traits, words).map
        {
            trait, word in
            SemanticBlock.paragraph(SemanticParagraph(runs: [
                SemanticRun(text: word + ": "),
                SemanticRun(text: "Native e\u{301} type", traits: [trait])
            ]))
        }
        let window = try WritingTestWindow(session: DocumentSession(
            state: WritingTestDocument(blocks: blocks).state
        ), size: NSSize(width: 840, height: 680))
        defer
        {
            window.close()
        }
        window.controller.documentWindow.appearance = NSAppearance(
            named: appearance
        )
        let before = window.storage
        for span in window.controller.bridge.projection.map.spans
        {
            window.select(NSMaxRange(span.range))
            window.view.scrollRangeToVisible(window.view.selectedRange())
            try WritingWindowGeometry.expectVisibleCaret(window)
        }
        let bitmap = try WritingWindowCapture.capture(window)
        #expect(try WritingWindowCapture.contrastingSamples(bitmap) > 100)
        try WritingWindowCapture.export(bitmap,
            name: "inline-appearance-" + appearance.rawValue)
        #expect(window.session.document.content ==
            before.state.snapshot.document.content)
    }
}
