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
    package let source: RasterGlyphSource
    package let firstGlyph: RasterGlyph
    package let remainingGlyphs: [RasterGlyph]

    package var sourceSlices: [RasterSourceSlice]
    {
        source.sourceSlices
    }

    package var glyphs: [RasterGlyph]
    {
        [firstGlyph] + remainingGlyphs
    }
}
