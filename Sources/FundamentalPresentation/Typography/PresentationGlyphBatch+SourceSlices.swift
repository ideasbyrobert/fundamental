extension PresentationGlyphBatch
{
    init(
        residentID: PresentationResidentID, paintOrder: Int,
        logicalBounds: PresentationRectangle,
        clipBounds: PresentationRectangle, pixelBounds: PresentationPixelBounds,
        font: PresentationFontIdentity, textMatrix: PresentationAffineTransform,
        baselineOffset: Double, color: PresentationColor,
        sourceSlices: [PresentationSourceSlice],
        firstGlyph: PresentationGlyph, remainingGlyphs: [PresentationGlyph]
    )
    {
        self.init(
            residentID: residentID, paintOrder: paintOrder,
            logicalBounds: logicalBounds, clipBounds: clipBounds,
            pixelBounds: pixelBounds, font: font, textMatrix: textMatrix,
            baselineOffset: baselineOffset, color: color,
            source: .text(sourceSlices), firstGlyph: firstGlyph,
            remainingGlyphs: remainingGlyphs
        )
    }
}
