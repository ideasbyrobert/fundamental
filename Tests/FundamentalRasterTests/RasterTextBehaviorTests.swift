import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

extension RasterTextTests
{
    @MainActor
    @Test("blank lines remain interactive without a counterfeit mark")
    func blankLine() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run("")
        ]))
        let layout = try RasterFixture.layout([block])
        let viewport = try RasterFixture.viewport(layout)
        let raster = try RasterFixture.snapshot(viewport)
        #expect(raster.marks.isEmpty)
        let region = raster.interactionMap.firstRegion
        guard case let .text(text) = region.content
        else
        {
            Issue.record("Expected text interaction")
            return
        }
        #expect(text.text.isEmpty)
        #expect(text.caretSites.map(\.utf16Offset) == [0])
        #expect(text.lineBounds.size.height > 0)
        #expect(text.baseline.y.isFinite)
        #expect(!text.defaultFont.postScriptName.isEmpty)
    }

    @MainActor
    @Test("equal input and specification publish equal instructions")
    func deterministic() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run("deterministic")
        ]))
        let layout = try RasterFixture.layout([block])
        let viewport = try RasterFixture.viewport(layout)
        let request = try RasterFixture.request(viewport)
        let rasterizer = ViewportRasterizer()
        #expect(rasterizer.rasterize(viewport, request: request)
            == rasterizer.rasterize(viewport, request: request))
    }
}
