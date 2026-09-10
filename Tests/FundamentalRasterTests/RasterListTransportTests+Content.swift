import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

extension RasterListTransportTests
{
    @Test("empty Unicode and multi-line items retain all layout facts",
          arguments: SemanticListKind.allCases, [
              "", "e\u{301} 👩🏽‍💻 Հայերեն Раздел",
              "first\nsecond\nthird",
              "Words that wrap across several visual lines in one list item."
          ])
    func content(kind: SemanticListKind, source: String) throws
    {
        let layout = try RasterFixture.layout([
            RasterListFixture.block(kind, source)
        ], width: 240)
        let raster = try RasterFixture.snapshot(RasterFixture.viewport(layout))
        let lines = RasterListFixture.lines(layout)
        let texts = RasterListFixture.texts(raster)
        #expect(texts.map(\.text).joined() == source)
        #expect(texts.compactMap(\.marker).count == 1)
        #expect(texts.count == lines.count)
        for (line, region) in zip(lines, raster.interactionMap.regions)
        {
            try RasterListFixture.expect(line, region: region, raster: raster)
            #expect(region.role.listPosition?.index == 0)
            #expect(region.role.listPosition?.count == 1)
        }
        if source.isEmpty
        {
            #expect(texts.first?.caretSites.count == 1)
            #expect(texts.first?.sourceSlices.isEmpty == true)
            #expect(RasterListFixture.batches(raster).allSatisfy
            {
                if case .listMarker = $0.source { return true }
                return false
            })
        }
        if source.contains("\n") || source.count > 50
        {
            #expect(lines.count > 1)
        }
    }
}
