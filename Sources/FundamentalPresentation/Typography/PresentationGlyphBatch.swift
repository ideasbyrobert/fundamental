package struct PresentationGlyphBatch: Equatable, Sendable
{
    package let residentID: PresentationResidentID
    package let paintOrder: Int
    package let logicalBounds: PresentationRectangle
    package let clipBounds: PresentationRectangle
    package let pixelBounds: PresentationPixelBounds
    package let font: PresentationFontIdentity
    package let textMatrix: PresentationAffineTransform
    package let baselineOffset: Double
    package let color: PresentationColor
    package let source: PresentationGlyphSource
    package let firstGlyph: PresentationGlyph
    package let remainingGlyphs: [PresentationGlyph]

    package var sourceSlices: [PresentationSourceSlice]
    {
        source.sourceSlices
    }

    package var glyphs: [PresentationGlyph]
    {
        [firstGlyph] + remainingGlyphs
    }
}
