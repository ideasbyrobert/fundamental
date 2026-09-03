extension NativeTextKit2Layout
{
    func translated(
        _ line: LayoutLine,
        dx: Double,
        dy: Double
    ) throws -> LayoutLine
    {
        LayoutLine(
            text: line.text,
            frame: try translated(line.frame, dx: dx, dy: dy),
            baseline: try point(
                x: line.baseline.x + dx,
                y: line.baseline.y + dy
            ),
            sourceSlices: line.sourceSlices,
            firstCaretStop: try translated(
                line.firstCaretStop,
                dx: dx,
                dy: dy
            ),
            remainingCaretStops: try line.remainingCaretStops.map
            {
                try translated($0, dx: dx, dy: dy)
            },
            defaultFont: line.defaultFont,
            glyphRuns: try line.glyphRuns.map
            {
                try translated($0, dx: dx, dy: dy)
            }
        )
    }

    func translated(
        _ stop: LayoutCaretStop,
        dx: Double,
        dy: Double
    ) throws -> LayoutCaretStop
    {
        LayoutCaretStop(
            utf16Offset: stop.utf16Offset,
            position: try point(
                x: stop.position.x + dx,
                y: stop.position.y + dy
            ),
            sourcePoint: stop.sourcePoint
        )
    }

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

    func translated(
        _ frame: LayoutRectangle,
        dx: Double,
        dy: Double
    ) throws -> LayoutRectangle
    {
        try rectangle(
            x: frame.origin.x + dx,
            y: frame.origin.y + dy,
            width: frame.size.width,
            height: frame.size.height
        )
    }
}
