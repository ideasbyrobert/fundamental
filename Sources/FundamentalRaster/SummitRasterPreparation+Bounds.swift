import FundamentalViewport

extension SummitRasterPreparation
{
    static func targetBounds(
        _ viewport: ViewportSnapshot
    ) -> RasterRectangle?
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
        guard maximumY > minimumY,
              let origin = RasterPoint(x: 0, y: minimumY),
              let size = RasterSize(
                  width: viewport.documentSize.width,
                  height: maximumY - minimumY
              )
        else
        {
            return nil
        }
        return RasterRectangle(origin: origin, size: size)
    }
}
