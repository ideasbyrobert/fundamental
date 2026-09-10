import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func line(
        _ nativeLine: NSTextLineFragment,
        fragment: NSTextLayoutFragment,
        selectionExtent: LayoutSelectionExtent,
        range: NSRange,
        attributed: NSAttributedString,
        text: NSString,
        segments: [NativeSourceSegment],
        defaultFont: LayoutFontIdentity,
        originX: Double,
        originY: Double,
        pointContext: NativeTextPointContext
    ) throws -> LayoutLine
    {
        guard NSMaxRange(range) <= attributed.length
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let fragmentFrame = fragment.layoutFragmentFrame
        let bounds = nativeLine.typographicBounds
        let lineX = originX + fragmentFrame.minX + bounds.minX
        let lineY = originY + fragmentFrame.minY + bounds.minY
        let frame = try rectangle(
            x: lineX,
            y: lineY,
            width: bounds.width,
            height: bounds.height
        )
        let glyph = nativeLine.glyphOrigin
        let baseline = try point(
            x: lineX + glyph.x,
            y: lineY + glyph.y
        )
        let sourceSlices = slices(
            for: range,
            segments: segments,
            text: text
        )
        let substring = attributed.attributedSubstring(from: range)
        let lineText = text.substring(with: range)
        guard sourceSlices.map(\.text).joined() == lineText,
              sourceSlices.reduce(0, { $0 + $1.range.count })
                == range.length
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let caretStops = try caretStops(
            nativeLine,
            text: lineText,
            originX: lineX,
            originY: lineY,
            nativeOffset: nativeLine.characterRange.location,
            containerOffset: range.location,
            pointContext: pointContext
        )
        let caretXs = caretStops.map(\.position.x)
        let textKitAdvance = caretXs.max()! - caretXs.min()!
        return LayoutLine(
            text: lineText,
            frame: frame,
            baseline: baseline,
            selectionExtent: selectionExtent,
            sourceSlices: sourceSlices,
            firstCaretStop: caretStops[0],
            remainingCaretStops: Array(caretStops.dropFirst()),
            defaultFont: defaultFont,
            glyphRuns: try glyphRuns(
                substring,
                textKitAdvance: textKitAdvance,
                documentOffset: range.location,
                baseline: baseline,
                segments: segments,
                text: text
            ),
            marker: nil
        )
    }
}
