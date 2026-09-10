extension NativeTextKit2Layout
{
    func validateListLine(
        _ line: LayoutLine,
        inset: Double,
        width: Double
    ) throws
    {
        guard line.frame.minX >= inset, line.frame.maxX <= width,
              line.caretStops.allSatisfy(
                  { $0.position.x >= inset && $0.position.x <= width }
              )
        else
        {
            throw LayoutFailure.unrepresentableListGeometry
        }
    }

    func listLine(
        _ line: LayoutLine,
        marker: LayoutListMarker
    ) throws -> LayoutLine
    {
        let x = min(line.frame.minX, marker.inkBounds.minX)
        let y = min(line.frame.minY, marker.inkBounds.minY)
        let right = max(line.frame.maxX, marker.inkBounds.maxX)
        let bottom = max(line.frame.maxY, marker.inkBounds.maxY)
        return LayoutLine(
            text: line.text,
            frame: try rectangle(
                x: x, y: y, width: right - x, height: bottom - y
            ),
            baseline: line.baseline,
            selectionExtent: line.selectionExtent,
            sourceSlices: line.sourceSlices,
            firstCaretStop: line.firstCaretStop,
            remainingCaretStops: line.remainingCaretStops,
            defaultFont: line.defaultFont,
            glyphRuns: line.glyphRuns,
            marker: marker
        )
    }
}
