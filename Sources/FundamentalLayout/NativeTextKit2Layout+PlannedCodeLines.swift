import AppKit
import FundamentalNativeWrapping
import FundamentalProjection

extension NativeTextKit2Layout
{
    func plannedCodeLines(
        runs: [ProjectedRun],
        width: Double,
        originX: Double,
        originY: Double,
        font: NSFont,
        pointContext: NativeTextPointContext
    ) throws -> [LayoutLine]
    {
        let (attributed, segments) = try attributedSource(
            runs: runs, font: font
        )
        guard let wrapping = NativeCodeWrapping.make(
            attributed, font: font, width: width
        )
        else
        {
            throw LayoutFailure.unrepresentableCodeWrapping
        }
        var result: [LayoutLine] = []
        var y = originY
        for measured in wrapping.lines
        {
            let line = try codeLine(
                measured, font: font, width: width,
                originX: originX, originY: y,
                segments: segments, text: attributed.string as NSString,
                pointContext: pointContext
            )
            result.append(line)
            y = line.frame.maxY
        }
        return result
    }
}
