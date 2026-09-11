import FundamentalLayout

extension ViewportResidentExtentWindow
{
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
