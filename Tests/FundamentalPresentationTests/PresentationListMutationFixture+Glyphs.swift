@testable import FundamentalRaster

extension PresentationListFixture
{
    static func batch(
        _ value: RasterGlyphBatch, source: RasterGlyphSource,
        glyphSlices: [RasterSourceSlice]? = nil
    ) -> RasterGlyphBatch
    {
        let glyph = value.firstGlyph
        return RasterGlyphBatch(
            residentID: value.residentID, paintOrder: value.paintOrder,
            logicalBounds: value.logicalBounds, clipBounds: value.clipBounds,
            pixelBounds: value.pixelBounds, font: value.font,
            textMatrix: value.textMatrix, baselineOffset: value.baselineOffset,
            color: value.color, source: source,
            firstGlyph: RasterGlyph(
                identifier: glyph.identifier, position: glyph.position,
                advance: glyph.advance,
                sourceSlices: glyphSlices ?? glyph.sourceSlices
            ),
            remainingGlyphs: value.remainingGlyphs
        )
    }
}
