@testable import FundamentalLayout

extension RasterListFixture
{
    static func line(
        _ value: LayoutLine, marker: LayoutListMarker?,
        extent: LayoutSelectionExtent? = nil
    ) -> LayoutLine
    {
        LayoutLine(
            text: value.text, frame: value.frame, baseline: value.baseline,
            selectionExtent: extent ?? value.selectionExtent,
            sourceSlices: value.sourceSlices,
            firstCaretStop: value.firstCaretStop,
            remainingCaretStops: value.remainingCaretStops,
            defaultFont: value.defaultFont, glyphRuns: value.glyphRuns,
            marker: marker
        )
    }

    static func marker(
        _ value: LayoutListMarker, run: LayoutGlyphRun
    ) -> LayoutListMarker
    {
        LayoutListMarker(
            source: value.source, baseline: value.baseline,
            advance: value.advance, inkBounds: value.inkBounds,
            firstGlyphRun: run, remainingGlyphRuns: value.remainingGlyphRuns
        )
    }

    static func run(
        _ value: LayoutGlyphRun, slices: [LayoutSourceSlice]? = nil,
        glyphSlices: [LayoutSourceSlice]? = nil,
        decorations: [LayoutDecoration]? = nil
    ) -> LayoutGlyphRun
    {
        let glyph = value.firstGlyph
        return LayoutGlyphRun(
            paintOrder: value.paintOrder, font: value.font,
            textMatrix: value.textMatrix, style: value.style,
            sourceSlices: slices ?? value.sourceSlices,
            decorations: decorations ?? value.decorations,
            firstGlyph: LayoutGlyph(
                identifier: glyph.identifier, position: glyph.position,
                advance: glyph.advance,
                sourceSlices: glyphSlices ?? glyph.sourceSlices
            ),
            remainingGlyphs: value.remainingGlyphs
        )
    }
}
