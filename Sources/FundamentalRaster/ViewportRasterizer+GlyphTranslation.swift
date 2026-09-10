import FundamentalViewport

extension ViewportRasterizer
{
    static func glyphs(
        _ run: ResidentLayoutGlyphRun
    ) -> [RasterGlyph]?
    {
        var result: [RasterGlyph] = []
        result.reserveCapacity(1 + run.remainingGlyphs.count)
        for glyph in run.glyphs
        {
            guard let position = RasterPoint(
                x: glyph.position.x, y: glyph.position.y
            )
            else
            {
                return nil
            }
            result.append(RasterGlyph(
                identifier: glyph.identifier,
                position: position,
                advance: RasterVector(
                    dx: glyph.advance.dx, dy: glyph.advance.dy
                ),
                sourceSlices: sourceSlices(glyph.sourceSlices)
            ))
        }
        return result
    }
}
