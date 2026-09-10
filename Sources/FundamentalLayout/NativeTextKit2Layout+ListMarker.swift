import AppKit
import CoreText

extension NativeTextKit2Layout
{
    func listMarker(
        _ source: LayoutListMarkerSource,
        baselineX: Double,
        baselineY: Double
    ) throws -> LayoutListMarker
    {
        let baseline = try point(x: baselineX, y: baselineY)
        let text = NSAttributedString(string: source.label,
            attributes: [.font: try proseFont(.body)])
        let line = CTLineCreateWithAttributedString(text)
        let advance = CTLineGetTypographicBounds(line, nil, nil, nil)
        guard advance.isFinite, advance >= 0
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
        let nativeRuns = CTLineGetGlyphRuns(line) as NSArray
        var runs: [LayoutGlyphRun] = []
        for index in 0 ..< nativeRuns.count
        {
            if let native = try NativeGlyphRun(
                nativeRuns[index] as! CTRun, sourceLength: text.length
            )
            {
                runs.append(try markerGlyphRun(
                    native, baseline: baseline, paintOrder: index
                ))
            }
        }
        guard let first = runs.first
        else
        {
            throw LayoutFailure.missingNativeLine
        }
        return LayoutListMarker(
            source: source,
            baseline: baseline,
            advance: advance,
            inkBounds: try rectangle(
                x: baseline.x + bounds.minX, y: baseline.y - bounds.maxY,
                width: bounds.width, height: bounds.height
            ),
            firstGlyphRun: first,
            remainingGlyphRuns: Array(runs.dropFirst())
        )
    }

    private func markerGlyphRun(
        _ native: NativeGlyphRun,
        baseline: LayoutPoint,
        paintOrder: Int
    ) throws -> LayoutGlyphRun
    {
        let glyphs = try glyphs(
            native, baseline: baseline, baselineOffset: 0
        )
        {
            _ in []
        }
        return LayoutGlyphRun(
            paintOrder: paintOrder,
            font: try fontIdentity(native.font),
            textMatrix: transform(native.matrix),
            style: LayoutRunStyle(baselineOffset: 0),
            sourceSlices: [], decorations: [],
            firstGlyph: glyphs[0],
            remainingGlyphs: Array(glyphs.dropFirst())
        )
    }
}
