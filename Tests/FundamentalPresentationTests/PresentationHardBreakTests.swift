import Testing

@testable import FundamentalPresentation

@MainActor
@Suite("Presentation hard-break feedback")
struct PresentationHardBreakTests
{
    @Test("terminal break feedback follows the resolved native direction",
          arguments: ["A\n", "אב\n", "אב AB\n"], [240.0, 480.0])
    func direction(text: String, width: Double) throws
    {
        let helpers = PresentationAdornmentTests()
        let raster = try helpers.textRaster(text, width: width)
        let snapshot = try PresentationFixture.snapshot(raster)
        let pair = try #require(PresentationFixture.textResidents(snapshot)
            .first { $0.1.text == text })
        let line = pair.1
        let anchor = try PresentationFixture.position(
            pair.0, line: line, caret: line.caretSites.count - 2
        )
        let focus = try PresentationFixture.position(
            pair.0, line: line, caret: line.caretSites.count - 1
        )
        let forward = try helpers.selection(
            raster, anchor: anchor, focus: focus
        )
        let reverse = try helpers.selection(
            raster, anchor: focus, focus: anchor
        )
        #expect(forward.text == "\n")
        #expect(forward.fragments == reverse.fragments)
        #expect(forward.firstFragment.range
            == text.utf16.count - 1 ..< text.utf16.count)
        let bounds = forward.firstFragment.logicalBounds
        #expect(bounds.size.width > 0)
        if text.hasPrefix("אב")
        {
            #expect(bounds.minX == line.selectionExtent.trailing)
        }
        else
        {
            #expect(bounds.maxX == line.selectionExtent.trailing)
        }
    }
}
