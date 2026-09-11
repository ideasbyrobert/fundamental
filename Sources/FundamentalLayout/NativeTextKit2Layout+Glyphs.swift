import CoreText

extension NativeTextKit2Layout
{
    func glyphs(
        _ run: NativeGlyphRun,
        baseline: LayoutPoint,
        sourceSlices: (CFIndex) throws -> [LayoutSourceSlice]
    ) throws -> [LayoutGlyph]
    {
        try run.glyphs.indices.map
        {
            index in
            let position = run.positions[index]
            let advance = run.advances[index]
            return LayoutGlyph(
                identifier: UInt32(run.glyphs[index]),
                position: try point(
                    x: baseline.x + position.x,
                    y: baseline.y - position.y
                ),
                advance: LayoutVector(dx: advance.width, dy: -advance.height),
                sourceSlices: try sourceSlices(run.indices[index])
            )
        }
    }

    func transform(_ matrix: CGAffineTransform) -> LayoutAffineTransform
    {
        LayoutAffineTransform(
            a: matrix.a, b: matrix.b, c: matrix.c,
            d: matrix.d, tx: matrix.tx, ty: matrix.ty
        )
    }
}
