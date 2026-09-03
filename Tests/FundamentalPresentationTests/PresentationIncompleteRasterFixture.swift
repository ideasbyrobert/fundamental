import Testing

@testable import FundamentalRaster

extension PresentationFixture
{
    static func rasterKeepingFirstAndLast(
        _ raster: RasterSnapshot
    ) throws -> RasterSnapshot
    {
        let regions = raster.interactionMap.regions
        let first = try #require(regions.first)
        let last = try #require(regions.last)
        #expect(regions.count > 2)
        let identifiers = Set([first.residentID, last.residentID])
        return RasterSnapshot(
            lineage: raster.lineage,
            documentSize: raster.documentSize,
            sourceAnchor: RasterSourceAnchor(
                residentID: first.residentID,
                relativeX: first.frame.minX
                    - raster.lineage.viewport.specification
                        .visibleBounds.minX,
                relativeY: first.frame.minY
                    - raster.lineage.viewport.specification
                        .visibleBounds.minY
            ),
            marks: raster.marks.filter
            {
                identifiers.contains($0.residentID)
            },
            interactionMap: RasterInteractionMap(
                firstRegion: first,
                remainingRegions: [last]
            )
        )
    }
}
