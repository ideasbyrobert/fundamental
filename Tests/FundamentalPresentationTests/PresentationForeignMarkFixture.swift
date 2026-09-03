import Testing

@testable import FundamentalRaster

extension PresentationFixture
{
    static func rasterWithForeignFillSource(
        _ raster: RasterSnapshot
    ) throws -> RasterSnapshot
    {
        let regions = raster.interactionMap.regions
        let foreign = try #require(regions.last?.residentID.blockID)
        var marks = raster.marks
        let index = try #require(marks.firstIndex
        {
            guard case let .fill(fill) = $0
            else
            {
                return false
            }
            return !fill.sourceSlices.isEmpty
        })
        guard case let .fill(fill) = marks[index]
        else
        {
            throw PresentationTestError.missingSelection
        }
        let slices = try fill.sourceSlices.map
        {
            guard case let .block(_, run, range) = $0.source
            else
            {
                throw PresentationTestError.missingSelection
            }
            return RasterSourceSlice(
                source: .block(
                    blockID: foreign,
                    run: run,
                    range: range
                ),
                scope: $0.scope,
                range: $0.range,
                text: $0.text
            )
        }
        marks[index] = .fill(RasterFill(
            residentID: fill.residentID,
            role: fill.role,
            logicalBounds: fill.logicalBounds,
            pixelBounds: fill.pixelBounds,
            color: fill.color,
            sourceSlices: slices
        ))
        return RasterSnapshot(
            lineage: raster.lineage,
            documentSize: raster.documentSize,
            sourceAnchor: raster.sourceAnchor,
            marks: marks,
            interactionMap: raster.interactionMap
        )
    }
}
