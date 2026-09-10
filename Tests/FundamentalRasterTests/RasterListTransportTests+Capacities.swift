import Testing

@testable import FundamentalRaster

extension RasterListTransportTests
{
    @Test("both capacity ledgers include generated labels glyphs and fonts")
    func capacities() throws
    {
        let layout = try RasterFixture.layout([
            RasterListFixture.block(
                .bulleted, "First e\u{301} 👩🏽‍💻", traits: [.underline]
            ),
            RasterListFixture.block(
                .bulleted, "Second", traits: [.strikethrough]
            ),
            RasterListFixture.block(.numbered, "Third", traits: [.underline]),
            RasterListFixture.block(.numbered, "Fourth")
        ], width: 320)
        let viewport = try RasterFixture.viewport(layout)
        let raster = try RasterFixture.snapshot(viewport)
        let values = RasterListFixture.values(RasterCounts(raster))
        #expect(values.allSatisfy { $0 > 1 })
        let exact = try RasterListFixture.capacities(values)
        let bounded = try RasterFixture.snapshot(viewport, capacities: exact)
        #expect(bounded.marks == raster.marks)
        #expect(bounded.interactionMap == raster.interactionMap)
        #expect(RasterListFixture.accumulates(raster, capacities: exact))
        let specification = raster.lineage.specification
        #expect(ViewportRasterizer.admits(
            viewport, targetBounds: specification.logicalBounds,
            capacities: exact
        ))
        for index in values.indices
        {
            var lowered = values
            lowered[index] -= 1
            let smaller = try RasterListFixture.capacities(lowered)
            if index == 8
            {
                #expect(RasterSpecificationIdentity(
                    logicalBounds: specification.logicalBounds,
                    backingScale: specification.backingScale,
                    appearance: specification.appearance,
                    colorSpace: specification.colorSpace,
                    palette: specification.palette, capacities: smaller
                ) == nil)
                continue
            }
            #expect(!ViewportRasterizer.admits(
                viewport, targetBounds: specification.logicalBounds,
                capacities: smaller
            ))
            #expect(!RasterListFixture.accumulates(
                raster, capacities: smaller
            ))
            let request = try RasterFixture.request(
                viewport, capacities: smaller
            )
            #expect(ViewportRasterizer().rasterize(
                viewport, request: request
            ) == nil)
        }
    }
}
