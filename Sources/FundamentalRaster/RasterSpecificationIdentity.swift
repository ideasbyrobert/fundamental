package struct RasterSpecificationIdentity: Equatable, Sendable
{
    package let logicalBounds: RasterRectangle
    package let pixelBounds: RasterPixelBounds
    package let backingScale: Double
    package let appearance: RasterAppearance
    package let colorSpace: RasterColorSpaceIdentity
    package let palette: RasterPalette
    package let capacities: RasterCapacities

    package init?(
        logicalBounds: RasterRectangle,
        backingScale: Double,
        appearance: RasterAppearance,
        colorSpace: RasterColorSpaceIdentity,
        palette: RasterPalette,
        capacities: RasterCapacities
    )
    {
        guard logicalBounds.size.width > 0,
              logicalBounds.size.height > 0,
              backingScale.isFinite,
              backingScale > 0,
              palette.colorSpace == colorSpace,
              let pixelBounds = RasterPixelBounds(
                  logicalBounds: logicalBounds,
                  backingScale: backingScale
              ),
              pixelBounds.area <= capacities.pixelArea
        else
        {
            return nil
        }
        self.logicalBounds = logicalBounds
        self.pixelBounds = pixelBounds
        self.backingScale = backingScale
        self.appearance = appearance
        self.colorSpace = colorSpace
        self.palette = palette
        self.capacities = capacities
    }
}
