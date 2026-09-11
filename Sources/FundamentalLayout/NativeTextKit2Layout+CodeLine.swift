import AppKit
import CoreText
import FundamentalNativeWrapping

extension NativeTextKit2Layout
{
    func codeLine(
        _ measured: NativeWrappingLine,
        font: NSFont,
        width: Double,
        originX: Double,
        originY: Double,
        segments: [NativeSourceSegment],
        text: NSString,
        pointContext: NativeTextPointContext
    ) throws -> LayoutLine
    {
        let metrics = NSLayoutManager()
        let defaultHeight = metrics.defaultLineHeight(for: font)
        let defaultBaseline = metrics.defaultBaselineOffset(for: font)
        var ascent = CTFontGetAscent(font as CTFont)
        var descent = CTFontGetDescent(font as CTFont)
        var leading = CTFontGetLeading(font as CTFont)
        if let native = measured.native
        {
            _ = CTLineGetTypographicBounds(
                native, &ascent, &descent, &leading
            )
        }
        let offset = max(defaultBaseline, ascent)
        let height = offset + max(defaultHeight - defaultBaseline,
                                  descent + leading)
        let x = originX + measured.inlineOffset
        let baseline = try point(x: x, y: originY + offset)
        let carets = try codeCarets(measured, baseline: baseline,
                                    pointContext: pointContext)
        guard height > 0, let extent = LayoutSelectionExtent(
            leading: originX, trailing: originX + width
        )
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return LayoutLine(
            text: measured.attributed.string,
            frame: try rectangle(
                x: x, y: originY, width: measured.advance, height: height
            ),
            baseline: baseline,
            selectionExtent: extent,
            sourceSlices: slices(
                for: NSRange(location: measured.range.lowerBound,
                             length: measured.range.count),
                segments: segments, text: text
            ),
            firstCaretStop: carets[0],
            remainingCaretStops: Array(carets.dropFirst()),
            defaultFont: try fontIdentity(font as CTFont),
            glyphRuns: try glyphRuns(measured, baseline: baseline,
                                     segments: segments, text: text),
            marker: nil
        )
    }
}
