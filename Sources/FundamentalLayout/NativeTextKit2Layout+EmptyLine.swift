import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func emptyLine(
        font: NSFont,
        width: Double,
        originX: Double,
        originY: Double,
        pointContext: NativeTextPointContext
    ) throws -> LayoutLine
    {
        let metrics = NSLayoutManager()
        let height = metrics.defaultLineHeight(for: font)
        let offset = metrics.defaultBaselineOffset(for: font)
        guard height > 0, offset >= 0, offset <= height,
              let extent = LayoutSelectionExtent(
                  leading: originX, trailing: originX + width
              )
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        let baseline = try point(x: originX, y: originY + offset)
        return LayoutLine(
            text: "",
            frame: try rectangle(
                x: originX, y: originY, width: 0, height: height
            ),
            baseline: baseline,
            selectionExtent: extent,
            sourceSlices: [],
            firstCaretStop: LayoutCaretStop(
                utf16Offset: 0,
                position: baseline,
                sourcePoint: textPoint(pointContext, utf16Offset: 0)
            ),
            remainingCaretStops: [],
            defaultFont: try fontIdentity(font as CTFont),
            glyphRuns: [],
            marker: nil
        )
    }
}
