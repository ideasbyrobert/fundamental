import Testing

@testable import FundamentalRaster

@Suite("Raster capacity refusal")
struct RasterCapacityTests
{
    @MainActor
    @Test("exact capacities succeed and every smaller capacity refuses")
    func exactAndExcess() throws
    {
        let layout = try RasterFixture.layout([
            RasterFixture.table()
        ], width: 360)
        let viewport = try RasterFixture.viewport(layout)
        let generous = try RasterFixture.snapshot(viewport)
        let counts = RasterCounts(generous)
        let exact = try capacities([
            counts.marks,
            counts.glyphs,
            counts.fills,
            counts.sourceSlices,
            counts.caretSites,
            counts.interactionRegions,
            counts.fontVariations,
            counts.residentUTF16Units,
            counts.pixelArea
        ])
        let exactRequest = try RasterFixture.request(
            viewport,
            capacities: exact
        )
        #expect(ViewportRasterizer().rasterize(
            viewport,
            request: exactRequest
        ) != nil)
        for index in 0 ..< 9
        {
            var values = [
                counts.marks,
                counts.glyphs,
                counts.fills,
                counts.sourceSlices,
                counts.caretSites,
                counts.interactionRegions,
                counts.fontVariations,
                counts.residentUTF16Units,
                counts.pixelArea
            ]
            values[index] -= 1
            let smaller = try capacities(values)
            if index == 8
            {
                let valid = try RasterFixture.specification(viewport)
                #expect(RasterSpecificationIdentity(
                    logicalBounds: valid.logicalBounds,
                    backingScale: valid.backingScale,
                    appearance: valid.appearance,
                    colorSpace: valid.colorSpace,
                    palette: valid.palette,
                    capacities: smaller
                ) == nil)
                continue
            }
            let admitted = try RasterFixture.specification(
                viewport,
                capacities: smaller
            )
            let request = RasterRequest(
                expectedViewportLineage: viewport.lineage,
                generation: 17,
                specification: admitted
            )
            #expect(ViewportRasterizer().rasterize(
                viewport,
                request: request
            ) == nil)
        }
    }

    private func capacities(
        _ values: [Int]
    ) throws -> RasterCapacities
    {
        try #require(RasterCapacities(
            marks: values[0],
            glyphs: values[1],
            fills: values[2],
            sourceSlices: values[3],
            caretSites: values[4],
            interactionRegions: values[5],
            fontVariations: values[6],
            residentUTF16Units: values[7],
            pixelArea: values[8]
        ))
    }
}
