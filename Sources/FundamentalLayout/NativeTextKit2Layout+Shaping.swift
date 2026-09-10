import AppKit
import CoreText

extension NativeTextKit2Layout
{
    func glyphRuns(
        _ attributed: NSAttributedString,
        textKitAdvance: Double,
        documentOffset: Int,
        baseline: LayoutPoint,
        segments: [NativeSourceSegment],
        text: NSString
    ) throws -> [LayoutGlyphRun]
    {
        let line = CTLineCreateWithAttributedString(attributed)
        let shapedAdvance = CTLineGetTypographicBounds(
            line,
            nil,
            nil,
            nil
        )
        guard shapedAdvance.isFinite,
              abs(shapedAdvance - textKitAdvance) < 0.5
        else
        {
            throw LayoutFailure.inconsistentNativeShaping(
                textKitWidth: textKitAdvance,
                coreTextWidth: shapedAdvance
            )
        }
        let nativeRuns = CTLineGetGlyphRuns(line) as NSArray
        var result: [LayoutGlyphRun] = []
        for paintOrder in 0 ..< nativeRuns.count
        {
            let nativeRun = nativeRuns[paintOrder] as! CTRun
            if let run = try glyphRun(
                nativeRun,
                attributed: attributed,
                documentOffset: documentOffset,
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
