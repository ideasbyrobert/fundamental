extension NativeTextKit2Layout
{
    func translated(
        _ run: LayoutGlyphRun,
        dx: Double,
        dy: Double
    ) throws -> LayoutGlyphRun
    {
        let glyphs = try run.glyphs.map
        {
            glyph in
            LayoutGlyph(
                identifier: glyph.identifier,
                position: try point(
                    x: glyph.position.x + dx,
                    y: glyph.position.y + dy
                ),
                advance: glyph.advance,
                sourceSlices: glyph.sourceSlices
            )
        }
        return LayoutGlyphRun(
            paintOrder: run.paintOrder,
            font: run.font,
            textMatrix: run.textMatrix,
            style: run.style,
            sourceSlices: run.sourceSlices,
            decorations: try run.decorations.map
            {
                LayoutDecoration(
                    kind: $0.kind,
                    frame: try translated($0.frame, dx: dx, dy: dy),
                    sourceSlices: $0.sourceSlices
                )
            },
            firstGlyph: glyphs[0],
            remainingGlyphs: Array(glyphs.dropFirst())
        )
    }
}
