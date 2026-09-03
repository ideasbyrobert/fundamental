import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

@Suite("Raster target initialization")
struct RasterBackgroundTests
{
    @MainActor
    @Test("document background remains a target fact not a mark")
    func documentBackground() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run("Background")
        ]))
        let viewport = try RasterFixture.viewport(
            RasterFixture.layout([block])
        )
        let raster = try RasterFixture.snapshot(viewport)
        let background = try RasterFixture.palette().documentBackground
        #expect(raster.lineage.specification.palette.documentBackground
            == background)
        #expect(raster.marks.allSatisfy
        {
            guard case let .fill(fill) = $0 else { return true }
            return fill.color != background
        })
    }
}
