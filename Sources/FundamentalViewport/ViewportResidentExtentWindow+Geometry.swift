import FundamentalLayout

extension ViewportResidentExtentWindow
{
    static func precedingBounds(
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

    static func followingBounds(
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

    static func sourceAnchor(
        visible: [ViewportResidentExtent],
        overscan: [ViewportResidentExtent],
        bounds: LayoutRectangle
    ) -> ViewportSourceAnchor?
    {
        let visibleAnchor = visible.sorted(by: isPaintOrdered)
            .first(where: \.canAnchor)
        guard let resident = visibleAnchor
                ?? overscan.first(where: \.canAnchor)
        else
        {
            return nil
        }
        return ViewportSourceAnchor(
            fragment: resident.extent.anchor,
            relativeX: resident.extent.frame.minX - bounds.minX,
            relativeY: resident.extent.frame.minY - bounds.minY
        )
    }
}
