@testable import FundamentalPresentation

extension MacRasterSnapshotFixture
{
    static func glyphBatch(
        _ source: PresentationGlyphBatch,
        color: PresentationColor
    ) -> PresentationGlyphBatch
    {
        PresentationGlyphBatch(
            residentID: source.residentID,
            paintOrder: source.paintOrder,
            logicalBounds: source.logicalBounds,
            clipBounds: source.clipBounds,
            pixelBounds: source.pixelBounds,
            font: source.font,
            textMatrix: source.textMatrix,
            baselineOffset: source.baselineOffset,
            color: color,
            sourceSlices: source.sourceSlices,
            firstGlyph: source.firstGlyph,
            remainingGlyphs: source.remainingGlyphs
        )
    }

    static func glyphBatch(
        _ source: PresentationGlyphBatch,
        firstGlyph: PresentationGlyph
    ) -> PresentationGlyphBatch
    {
        PresentationGlyphBatch(
            residentID: source.residentID,
            paintOrder: source.paintOrder,
            logicalBounds: source.logicalBounds,
            clipBounds: source.clipBounds,
            pixelBounds: source.pixelBounds,
            font: source.font,
            textMatrix: source.textMatrix,
            baselineOffset: source.baselineOffset,
            color: source.color,
            sourceSlices: source.sourceSlices,
            firstGlyph: firstGlyph,
            remainingGlyphs: source.remainingGlyphs
        )
    }
}
