import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationAdornmentTests
{
    @MainActor
    @Test("hard-break selection uses the native container extent",
          arguments: ["\n", "\r", "\r\n", "\u{2028}", "\u{2029}"])
    func newlineOnlySelection(text: String) throws
    {
        let block = SemanticBlock.code(.plain(PlainSemanticCodeBlock(runs: [
            PresentationFixture.run(text)
        ])))
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([block], width: 300)
            )
        )
        let snapshot = try PresentationFixture.snapshot(raster)
        let pair = try #require(
            PresentationFixture.textResidents(snapshot).first
            {
                $0.1.text == text && $0.1.caretSites.count == 2
            }
        )
        let anchor = try PresentationFixture.position(
            pair.0,
            line: pair.1,
            caret: 0
        )
        let focus = try PresentationFixture.position(
            pair.0,
            line: pair.1,
            caret: 1
        )
        let selected = try selection(raster, anchor: anchor, focus: focus)
        #expect(selected.text.utf16.elementsEqual(text.utf16))
        #expect(selected.sourceSlices.map(\.text).joined()
            .utf16.elementsEqual(text.utf16))
        let bounds = selected.firstFragment.logicalBounds
        #expect(bounds.minX == pair.1.selectionExtent.minX)
        #expect(bounds.maxX == pair.1.selectionExtent.maxX)
        #expect(bounds.size.height == pair.1.lineBounds.size.height)
        #expect(selected.firstFragment.range == 0 ..< text.utf16.count)
    }
}
