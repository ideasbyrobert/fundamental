import Testing

@testable import FundamentalRaster
@testable import FundamentalViewport

extension PresentationFixture
{
    static func rasterBounds(
        _ viewport: ViewportSnapshot
    ) throws -> RasterRectangle
    {
        let specification = viewport.lineage.specification
        let minimumY = max(
            0,
            specification.visibleBounds.minY
                - specification.precedingOverscanExtent
        )
        let maximumY = min(
            viewport.documentSize.height,
            specification.visibleBounds.maxY
                + specification.followingOverscanExtent
        )
        let origin = try #require(RasterPoint(x: 0, y: minimumY))
        let size = try #require(RasterSize(
            width: viewport.documentSize.width,
            height: maximumY - minimumY
        ))
        return try #require(RasterRectangle(
            origin: origin,
            size: size
        ))
    }
}
