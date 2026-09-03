import Testing

@testable import FundamentalRaster

extension PresentationFixture
{
    static func rasterWithNegativePlane(
        _ raster: RasterSnapshot
    ) throws -> RasterSnapshot
    {
        let old = raster.lineage.specification
        let origin = try #require(RasterPoint(
            x: -1,
            y: old.logicalBounds.minY
        ))
        let size = try #require(RasterSize(
            width: old.logicalBounds.size.width + 1,
            height: old.logicalBounds.size.height
        ))
        let bounds = try #require(RasterRectangle(
            origin: origin,
            size: size
        ))
        let specification = try #require(RasterSpecificationIdentity(
            logicalBounds: bounds,
            backingScale: old.backingScale,
            appearance: old.appearance,
            colorSpace: old.colorSpace,
            palette: old.palette,
            capacities: old.capacities
        ))
        return RasterSnapshot(
            lineage: RasterLineage(
                viewport: raster.lineage.viewport,
                generation: raster.lineage.generation,
                specification: specification
            ),
            documentSize: raster.documentSize,
            sourceAnchor: raster.sourceAnchor,
            marks: raster.marks,
            interactionMap: raster.interactionMap
        )
    }
}
