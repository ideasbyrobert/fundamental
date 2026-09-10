import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("link decoration stays separate from underline in both appearances",
          arguments: [NSAppearance.Name.aqua, .darkAqua])
    func nativeScopeDrawing(_ appearance: NSAppearance.Name) throws
    {
        let words = ["Link: Exact e\u{301} 😀 text",
                     "Русский текст: слова и язык.",
                     "Связанный текст: язык и ссылка."]
        let scopes = try WritingScopeFixture.scopes()
        let blocks = words.enumerated().map
        {
            index, word in
            SemanticBlock.paragraph(SemanticParagraph(runs: [
                SemanticRun(text: word, attributes: .scoped(
                    traits: index == 2 ? [.emphasis] : [], scopes: scopes[index]
                ))
            ]))
        } + [.paragraph(SemanticParagraph(runs: [SemanticRun(
            text: "Underline remains independent.", traits: [.underline]
        )]))]
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
        let storage = try #require(window.view.textStorage)
        #expect(storage.attribute(.underlineStyle, at: 0,
                                  effectiveRange: nil) as? Int == 0)
        let layout = try #require(window.view.textLayoutManager)
        let content = try #require(layout.textContentManager)
        let rendering = layout.renderingAttributes(
            forLink: WritingScopeFixture.link,
            at: content.documentRange.location
        )
        #expect(rendering[.underlineStyle] as? Int == 1)
        #expect(rendering[.foregroundColor] is NSColor)
        for span in window.controller.bridge.projection.map.spans
        {
            window.select(NSMaxRange(span.range))
            window.view.scrollRangeToVisible(window.view.selectedRange())
            try WritingWindowGeometry.expectVisibleCaret(window)
        }
        let bitmap = try WritingWindowCapture.capture(window)
        #expect(try WritingWindowCapture.contrastingSamples(bitmap) > 100)
        try WritingWindowCapture.export(bitmap,
            name: "scope-appearance-" + appearance.rawValue)
        #expect(window.session.document.content ==
            before.state.snapshot.document.content)
    }
}
