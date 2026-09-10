import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

extension RasterListTransportTests
{
    @Test("numbering crosses decimal boundaries without changing source",
          arguments: SemanticListKind.allCases)
    func numbering(kind: SemanticListKind) throws
    {
        let blocks = (1 ... 100).map
        {
            RasterListFixture.block(kind, "Item \($0)")
        }
        let layout = try RasterFixture.layout(blocks, width: 240)
        let raster = try RasterFixture.snapshot(
            RasterFixture.viewport(layout),
            capacities: RasterFixture.capacities(value: 10_000_000)
        )
        let texts = RasterListFixture.texts(raster)
        #expect(texts.count == 100)
        for number in [1, 9, 10, 99, 100]
        {
            let marker = try #require(texts[number - 1].marker)
            #expect(marker.source.position.number == number)
            #expect(marker.source.position.count == 100)
            #expect(marker.source.label
                == (kind == .numbered ? "\(number)." : "•"))
            #expect(texts[number - 1].text == "Item \(number)")
        }
        for (line, region) in zip(
            RasterListFixture.lines(layout), raster.interactionMap.regions
        )
        {
            try RasterListFixture.expect(line, region: region, raster: raster)
        }
    }

    @Test("body and kind boundaries restart independent list runs")
    func independentRuns() throws
    {
        let layout = try RasterFixture.layout([
            RasterListFixture.block(.numbered, "A"),
            RasterListFixture.block(.numbered, ""),
            RasterListFixture.block(.bulleted, "B"),
            .paragraph(SemanticParagraph(runs: [RasterFixture.run("Body")])),
            RasterListFixture.block(.numbered, "C")
        ])
        let raster = try RasterFixture.snapshot(RasterFixture.viewport(layout))
        let markers = RasterListFixture.texts(raster).compactMap(\.marker)
        #expect(markers.map { $0.source.position.index } == [0, 1, 0, 0])
        #expect(markers.map { $0.source.position.count } == [2, 2, 1, 1])
        #expect(markers.map { $0.source.label } == ["1.", "2.", "•", "1."])
    }
}
