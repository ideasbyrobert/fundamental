package struct RasterFill: Equatable, Sendable
{
    package let residentID: RasterResidentID
    package let role: RasterFillRole
    package let logicalBounds: RasterRectangle
    package let pixelBounds: RasterPixelBounds
    package let color: RasterColor
    package let sourceSlices: [RasterSourceSlice]
}
