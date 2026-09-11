import CoreText
import FundamentalNativeWrapping

extension NativeTextKit2Layout
{
    func codeCarets(
        _ measured: NativeWrappingLine,
        baseline: LayoutPoint,
        pointContext: NativeTextPointContext
    ) throws -> [LayoutCaretStop]
    {
        var offsets = [0]
        for character in measured.attributed.string
        {
            offsets.append(offsets.last! + character.utf16.count)
        }
        return try offsets.map
        {
            offset in
            let x = measured.native.map
            {
                CTLineGetOffsetForStringIndex($0, offset, nil)
            } ?? 0
            return LayoutCaretStop(
                utf16Offset: offset,
                position: try point(x: baseline.x + x, y: baseline.y),
                sourcePoint: textPoint(pointContext,
                    utf16Offset: measured.range.lowerBound + offset)
            )
        }
    }
}
