@testable import FundamentalRaster

extension PresentationFixture
{
    static func rasterReversingMarks(
        _ raster: RasterSnapshot
    ) -> RasterSnapshot
    {
        RasterSnapshot(
            lineage: raster.lineage,
            documentSize: raster.documentSize,
            sourceAnchor: raster.sourceAnchor,
            marks: Array(raster.marks.reversed()),
            interactionMap: raster.interactionMap
        )
    }
}
