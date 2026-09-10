import Testing

@testable import FundamentalPresentation

extension MacReaderListPixelFixture
{
    static func changedBatch(
        _ batch: PresentationGlyphBatch, source: PresentationGlyphSource,
        position: PresentationPoint?, slices: [PresentationSourceSlice]?
    ) -> PresentationGlyphBatch
    {
        let glyph = batch.firstGlyph
        return PresentationGlyphBatch(
            residentID: batch.residentID, paintOrder: batch.paintOrder,
            logicalBounds: batch.logicalBounds, clipBounds: batch.clipBounds,
            pixelBounds: batch.pixelBounds, font: batch.font,
            textMatrix: batch.textMatrix, baselineOffset: batch.baselineOffset,
            color: batch.color, source: source,
            firstGlyph: PresentationGlyph(
                identifier: glyph.identifier,
                position: position ?? glyph.position, advance: glyph.advance,
                sourceSlices: slices ?? glyph.sourceSlices
            ),
            remainingGlyphs: batch.remainingGlyphs
        )
    }

    static func changedMarker(
        _ marker: PresentationListMarker, source: PresentationListMarkerSource,
        baseline: PresentationPoint? = nil
    ) throws -> PresentationListMarker
    {
        try #require(PresentationListMarker(
            source: source, baseline: baseline ?? marker.baseline,
            advance: marker.advance, inkBounds: marker.inkBounds
        ))
    }
}
