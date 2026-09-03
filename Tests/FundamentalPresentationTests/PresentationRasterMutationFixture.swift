import Testing

@testable import FundamentalRaster

extension PresentationFixture
{
    static func rasterWithDarkAppearance(
        _ raster: RasterSnapshot
    ) throws -> RasterSnapshot
    {
        let old = raster.lineage.specification
        let specification = try #require(RasterSpecificationIdentity(
            logicalBounds: old.logicalBounds,
            backingScale: old.backingScale,
            appearance: RasterAppearance(
                luminosity: .dark,
                contrast: old.appearance.contrast
            ),
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
