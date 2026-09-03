package struct LayoutGlyphRun: Equatable, Sendable
{
    package let paintOrder: Int
    package let font: LayoutFontIdentity
    package let textMatrix: LayoutAffineTransform
    package let style: LayoutRunStyle
    package let sourceSlices: [LayoutSourceSlice]
    package let decorations: [LayoutDecoration]
    package let firstGlyph: LayoutGlyph
    package let remainingGlyphs: [LayoutGlyph]

    package var glyphs: [LayoutGlyph]
    {
        [firstGlyph] + remainingGlyphs
    }
}
