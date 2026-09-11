import FundamentalLayout

enum ViewportOverscanBounds
{
    static func preceding(
        _ request: ViewportRequest
    ) -> LayoutRectangle?
    {
        guard let origin = LayoutPoint(
                  x: request.visibleBounds.minX,
                  y: request.visibleBounds.minY
                    - request.precedingOverscanExtent
              ),
              let size = LayoutSize(
                  width: request.visibleBounds.size.width,
                  height: request.precedingOverscanExtent
              )
        else
        {
            return nil
        }
        return LayoutRectangle(origin: origin, size: size)
    }

    static func following(
        _ request: ViewportRequest
    ) -> LayoutRectangle?
    {
        guard let origin = LayoutPoint(
                  x: request.visibleBounds.minX,
                  y: request.visibleBounds.maxY
              ),
              let size = LayoutSize(
                  width: request.visibleBounds.size.width,
                  height: request.followingOverscanExtent
              )
        else
        {
            return nil
        }
        return LayoutRectangle(origin: origin, size: size)
    }
}
