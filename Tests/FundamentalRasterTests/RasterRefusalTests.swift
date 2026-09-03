import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

@Suite("Raster atomic refusal")
struct RasterRefusalTests
{
    @MainActor
    @Test("stale viewport lineage refuses without publication")
    func staleLineage() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run("stale")
        ]))
        let layout = try RasterFixture.layout([block])
        let first = try RasterFixture.viewport(layout)
        let second = try RasterFixture.viewport(
            layout,
            generation: 14
        )
        let base = try RasterFixture.request(first)
        let request = RasterRequest(
            expectedViewportLineage: second.lineage,
            generation: base.generation,
            specification: base.specification
        )
        #expect(ViewportRasterizer().rasterize(
            first,
            request: request
        ) == nil)
    }

    @MainActor
    @Test("a target other than the complete resident band refuses")
    func targetMismatch() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run("bounds")
        ]))
        let layout = try RasterFixture.layout([block])
        let viewport = try RasterFixture.viewport(layout)
        let valid = try RasterFixture.specification(viewport)
        let wrong = try RasterFixture.rectangle(
            x: 0,
            y: valid.logicalBounds.minY,
            width: valid.logicalBounds.size.width,
            height: valid.logicalBounds.size.height / 2
        )
        let specification = try #require(RasterSpecificationIdentity(
            logicalBounds: wrong,
            backingScale: valid.backingScale,
            appearance: valid.appearance,
            colorSpace: valid.colorSpace,
            palette: valid.palette,
            capacities: valid.capacities
        ))
        let request = RasterRequest(
            expectedViewportLineage: viewport.lineage,
            generation: 17,
            specification: specification
        )
        #expect(ViewportRasterizer().rasterize(
            viewport,
            request: request
        ) == nil)
    }
}
