package struct RasterGlyphBatch: Equatable, Sendable
{
    package let residentID: RasterResidentID
    package let paintOrder: Int
    package let logicalBounds: RasterRectangle
    package let clipBounds: RasterRectangle
    package let pixelBounds: RasterPixelBounds
    package let font: RasterFontIdentity
    package let textMatrix: RasterAffineTransform
    package let baselineOffset: Double
    package let color: RasterColor
    package let sourceSlices: [RasterSourceSlice]
    package let firstGlyph: RasterGlyph
    package let remainingGlyphs: [RasterGlyph]

    package var glyphs: [RasterGlyph]
    {
        [firstGlyph] + remainingGlyphs
    }
}
