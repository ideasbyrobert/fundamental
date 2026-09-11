import AppKit
import CoreText
import FundamentalNativeWrapping

extension NativeTextKit2Layout
{
    func glyphRuns(
        _ shaping: NativeWrappingText,
        range: NSRange,
        inlineOffset: Double,
        textKitAdvance: Double,
        baseline: LayoutPoint,
        segments: [NativeSourceSegment],
        text: NSString
    ) throws -> [LayoutGlyphRun]
    {
        guard let measured = shaping.line(
            in: range.location ..< NSMaxRange(range),
            inlineOffset: inlineOffset
        )
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        guard abs(measured.advance - textKitAdvance) < 0.5
        else
        {
            throw LayoutFailure.inconsistentNativeShaping(
                textKitWidth: textKitAdvance,
                coreTextWidth: measured.advance
            )
        }
        return try glyphRuns(measured, baseline: baseline,
                             segments: segments, text: text)
    }

    func glyphRuns(
        _ measured: NativeWrappingLine,
        baseline: LayoutPoint,
        segments: [NativeSourceSegment],
        text: NSString
    ) throws -> [LayoutGlyphRun]
    {
        guard let line = measured.native
        else
        {
            return []
        }
        let nativeRuns = CTLineGetGlyphRuns(line) as NSArray
        var result: [LayoutGlyphRun] = []
        for paintOrder in 0 ..< nativeRuns.count
        {
            let nativeRun = nativeRuns[paintOrder] as! CTRun
            if let run = try glyphRun(
                nativeRun,
                attributed: measured.attributed,
                documentOffset: measured.range.lowerBound,
                baseline: baseline,
                segments: segments,
                text: text,
                paintOrder: paintOrder
            )
            {
                result.append(run)
            }
        }
        return result
    }
}
