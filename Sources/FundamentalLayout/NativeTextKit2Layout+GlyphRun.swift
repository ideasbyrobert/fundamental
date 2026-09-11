import AppKit
import CoreText

extension NativeTextKit2Layout
{
    func glyphRun(
        _ run: CTRun,
        attributed: NSAttributedString,
        documentOffset: Int,
        baseline: LayoutPoint,
        segments: [NativeSourceSegment],
        text: NSString,
        paintOrder: Int
    ) throws -> LayoutGlyphRun?
    {
        guard let native = try NativeGlyphRun(run,
                                              sourceLength: attributed.length)
        else
        {
            return nil
        }
        let range = native.range
        let identity = try fontIdentity(native.font)
        let style = runStyle(attributed, runRange: range)
        let runSlices = slices(
            for: NSRange(
                location: documentOffset + range.location, length: range.length
            ),
            segments: segments, text: text
        )
        let logicalIndices = Set(native.indices.filter
        {
            $0 >= range.location && $0 < range.location + range.length
        }).sorted()
        let glyphs = try glyphs(
            native, baseline: baseline
        )
        {
            try glyphSlices(
                stringIndex: $0, logicalIndices: logicalIndices,
                runRange: range, documentOffset: documentOffset,
                segments: segments, text: text
            )
        }
        return LayoutGlyphRun(
            paintOrder: paintOrder,
            font: identity,
            textMatrix: transform(native.matrix),
            style: style,
            sourceSlices: runSlices,
            decorations: try decorations(
                attributed, runRange: range, font: identity, baseline: baseline,
                positions: native.positions, advances: native.advances,
                sourceSlices: runSlices
            ),
            firstGlyph: glyphs[0],
            remainingGlyphs: Array(glyphs.dropFirst())
        )
    }
}
