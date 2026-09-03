package struct RasterGlyph: Equatable, Sendable
{
    package let identifier: UInt32
    package let position: RasterPoint
    package let advance: RasterVector
    package let sourceSlices: [RasterSourceSlice]
}
