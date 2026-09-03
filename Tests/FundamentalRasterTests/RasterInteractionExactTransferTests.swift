import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalRaster

extension RasterTextTests
{
    @MainActor
    @Test("every interaction line fact crosses the raster boundary exactly")
    func exactInteractionTransfer() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run("A e\u{301} 👨‍👩‍👧‍👦")
        ]))
        let layout = try RasterFixture.layout([block], width: 500)
        let raster = try RasterFixture.snapshot(
            RasterFixture.viewport(layout)
        )
        guard case let .lines(fragment) = layout.firstFragment,
              case let .text(text) = raster.interactionMap
                  .firstRegion.content
        else
        {
            Issue.record("Expected an interaction text line")
            return
        }
        let line = fragment.line
        let lineBounds = try RasterFixture.rectangle(
            x: line.frame.minX,
            y: line.frame.minY,
            width: line.frame.size.width,
            height: line.frame.size.height
        )
        let baseline = try #require(RasterPoint(
            x: line.baseline.x,
            y: line.baseline.y
        ))
        let carets = try line.caretStops.map
        {
            try RasterFixture.expectedCaretSite($0)
        }
        #expect(text.text == line.text)
        #expect(text.defaultFont
            == RasterFixture.expectedFont(line.defaultFont))
        #expect(text.lineBounds == lineBounds)
        #expect(text.baseline == baseline)
        #expect(text.sourceSlices
            == RasterFixture.expectedSlices(line.sourceSlices))
        #expect(text.caretSites == carets)
    }
}
