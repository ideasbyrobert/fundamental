import Testing

@testable import FundamentalRaster

extension RasterListFixture
{
    static func values(_ counts: RasterCounts) -> [Int]
    {
        [
            counts.marks, counts.glyphs, counts.fills, counts.sourceSlices,
            counts.caretSites, counts.interactionRegions,
            counts.fontVariations, counts.residentUTF16Units, counts.pixelArea
        ]
    }

    static func capacities(_ values: [Int]) throws -> RasterCapacities
    {
        try #require(RasterCapacities(
            marks: values[0], glyphs: values[1], fills: values[2],
            sourceSlices: values[3], caretSites: values[4],
            interactionRegions: values[5], fontVariations: values[6],
            residentUTF16Units: values[7], pixelArea: values[8]
        ))
    }

    static func accumulates(
        _ raster: RasterSnapshot, capacities: RasterCapacities
    ) -> Bool
    {
        var accumulator = RasterAccumulator(capacities: capacities)
        for mark in raster.marks
        {
            let accepted: Bool
            switch mark
            {
            case let .glyphs(batch):
                accepted = accumulator.append(batch)
            case let .fill(fill):
                accepted = accumulator.append(fill)
            }
            if !accepted { return false }
        }
        return raster.interactionMap.regions.allSatisfy
        {
            accumulator.append($0)
        }
    }
}
