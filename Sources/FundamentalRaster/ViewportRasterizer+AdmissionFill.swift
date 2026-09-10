extension ViewportRasterizer
{
    static func consumeFill(
        _ bounds: RasterRectangle?,
        targetBounds: RasterRectangle,
        budget: inout RasterAdmissionBudget
    ) -> Bool
    {
        guard let bounds,
              bounds.intersection(targetBounds) != nil
        else
        {
            return bounds != nil
        }
        return budget.consumeFill()
    }
}
