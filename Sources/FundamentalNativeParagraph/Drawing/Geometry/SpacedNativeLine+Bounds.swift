import CoreText

extension SpacedNativeLine
{
    package var inkBounds: CGRect
    {
        runs.reduce(CGRect.null)
        {
            result, run in
            var result = result
            var glyphs = run.glyphs.map(\.original.identifier)
            var bounds = [CGRect](repeating: .zero, count: glyphs.count)
            CTFontGetBoundingRectsForGlyphs(
                run.font, .horizontal, &glyphs, &bounds, glyphs.count
            )
            for index in run.glyphs.indices where !bounds[index].isEmpty
            {
                let glyph = run.glyphs[index]
                result = result.union(bounds[index].offsetBy(
                    dx: glyph.position.x, dy: glyph.position.y
                ))
            }
            for decoration in run.decorations
            {
                result = result.union(decoration.bounds)
            }
            return result
        }
    }
}
