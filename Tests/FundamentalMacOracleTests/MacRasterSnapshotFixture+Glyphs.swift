@testable import FundamentalPresentation

extension MacRasterSnapshotFixture
{
    static func firstTextBatch(
        in snapshot: PresentationSnapshot
    ) -> PresentationGlyphBatch?
    {
        snapshot.presentedDocument.marks.compactMap
        {
            guard case let .glyphs(batch) = $0,
                  batch.font.postScriptName != ".AppleColorEmojiUI"
            else
            {
                return nil
            }
            return batch
        }.first
    }

    static func glyphBatch(
        _ source: PresentationGlyphBatch,
        glyphs: [PresentationGlyph],
        clip: PresentationRectangle,
        pixels: PresentationPixelBounds
    ) -> PresentationGlyphBatch?
    {
        guard let first = glyphs.first
        else
        {
            return nil
        }
        return PresentationGlyphBatch(
            residentID: source.residentID,
            paintOrder: source.paintOrder,
            logicalBounds: source.logicalBounds,
            clipBounds: clip,
            pixelBounds: pixels,
            font: source.font,
            textMatrix: source.textMatrix,
            baselineOffset: source.baselineOffset,
            color: source.color,
            sourceSlices: source.sourceSlices,
            firstGlyph: first,
            remainingGlyphs: Array(glyphs.dropFirst())
        )
    }

    static func shifting(
        _ source: PresentationGlyphBatch,
        x: Double,
        y: Double,
        clip: PresentationRectangle,
        pixels: PresentationPixelBounds
    ) -> PresentationGlyphBatch?
    {
        var glyphs: [PresentationGlyph] = []
        for glyph in source.glyphs
        {
            guard let position = PresentationPoint(
                x: glyph.position.x + x,
                y: glyph.position.y + y
            )
            else
            {
                return nil
            }
            glyphs.append(PresentationGlyph(
                identifier: glyph.identifier,
                position: position,
                advance: glyph.advance,
                sourceSlices: glyph.sourceSlices
            ))
        }
        return glyphBatch(
            source,
            glyphs: glyphs,
            clip: clip,
            pixels: pixels
        )
    }
}
