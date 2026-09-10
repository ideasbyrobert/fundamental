import Testing

@testable import FundamentalLayout
@testable import FundamentalRaster

extension RasterListFixture
{
    static func expect(
        _ fragment: LayoutLineFragment,
        region: RasterInteractionRegion, raster: RasterSnapshot
    ) throws
    {
        let line = fragment.line
        let identifier = RasterResidentID(
            blockID: fragment.anchor.blockID,
            blockOrdinal: fragment.anchor.blockOrdinal,
            fragmentOrdinal: fragment.anchor.fragmentOrdinal
        )
        guard case let .text(text) = region.content
        else
        {
            Issue.record("Expected list interaction text")
            return
        }
        #expect(region.residentID == identifier)
        #expect(region.frame == (try bounds(fragment.frame)))
        #expect(text.text == line.text)
        #expect(text.defaultFont
            == RasterFixture.expectedFont(line.defaultFont))
        #expect(text.lineBounds == (try bounds(line.frame)))
        #expect(text.baseline == (try point(line.baseline)))
        #expect(text.sourceSlices
            == RasterFixture.expectedSlices(line.sourceSlices))
        #expect(text.caretSites
            == (try line.caretStops.map(RasterFixture.expectedCaretSite)))
        if let native = line.marker
        {
            let marker = try #require(text.marker)
            #expect(marker.source.residentID == identifier)
            #expect(marker.source.role == region.role)
            #expect(marker.source.position.index
                == native.source.position.index)
            #expect(marker.source.position.count
                == native.source.position.count)
            #expect(marker.source.label == native.source.label)
            #expect(marker.baseline == (try point(native.baseline)))
            #expect(marker.advance == native.advance)
            #expect(marker.inkBounds == (try bounds(native.inkBounds)))
        }
        else
        {
            #expect(text.marker == nil)
        }
        let actual = batches(raster).filter { $0.residentID == identifier }
        let expected = (line.marker?.glyphRuns ?? []) + line.glyphRuns
        #expect(actual.count == expected.count)
        for (index, pair) in zip(actual, expected).enumerated()
        {
            try expect(
                pair.0, run: pair.1, line: line,
                frame: fragment.frame, raster: raster
            )
            if index < (line.marker?.glyphRuns.count ?? 0)
            {
                let marker = try #require(text.marker)
                #expect(pair.0.source == .listMarker(marker.source))
            }
            else
            {
                #expect(pair.0.source == .text(
                    RasterFixture.expectedSlices(pair.1.sourceSlices)
                ))
            }
        }
        try expectDecorations(line, owner: identifier, raster: raster)
    }
}
