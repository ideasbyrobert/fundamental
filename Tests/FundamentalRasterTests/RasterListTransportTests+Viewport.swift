import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

extension RasterListTransportTests
{
    @Test("a resident continuation retains context without its absent marker",
          arguments: SemanticListKind.allCases)
    func continuation(kind: SemanticListKind) throws
    {
        let source = "Readable source continues across several visual lines."
        let layout = try RasterFixture.layout([
            RasterListFixture.block(kind, source)
        ], width: 180)
        let lines = RasterListFixture.lines(layout)
        let middle = try #require(lines.dropFirst().first)
        let viewport = try RasterFixture.viewport(
            layout, y: middle.frame.minY + 0.5,
            height: middle.frame.size.height - 1
        )
        let raster = try RasterFixture.snapshot(viewport)
        #expect(!raster.interactionMap.regions.isEmpty)
        for region in raster.interactionMap.regions
        {
            #expect(region.residentID.fragmentOrdinal > 0)
            #expect(region.role.listPosition?.index == 0)
            #expect(region.role.listPosition?.count == 1)
            let fragment = try #require(lines.first
            {
                $0.anchor.fragmentOrdinal == region.residentID.fragmentOrdinal
            })
            try RasterListFixture.expect(
                fragment, region: region, raster: raster
            )
        }
        #expect(RasterListFixture.texts(raster).allSatisfy
        {
            $0.marker == nil
        })
        #expect(RasterListFixture.batches(raster).allSatisfy
        {
            if case .text = $0.source { return true }
            return false
        })
    }
}
