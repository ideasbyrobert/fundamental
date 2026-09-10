extension NativeTextKit2Layout
{
    func translated(
        _ line: LayoutLine,
        dx: Double,
        dy: Double,
        containerDX: Double? = nil
    ) throws -> LayoutLine
    {
        LayoutLine(
            text: line.text,
            frame: try translated(line.frame, dx: dx, dy: dy),
            baseline: try point(
                x: line.baseline.x + dx,
                y: line.baseline.y + dy
            ),
            selectionExtent: try translated(
                line.selectionExtent, dx: containerDX ?? dx
            ),
            sourceSlices: line.sourceSlices,
            firstCaretStop: try translated(
                line.firstCaretStop,
                dx: dx,
                dy: dy
            ),
            remainingCaretStops: try line.remainingCaretStops.map
            {
                try translated($0, dx: dx, dy: dy)
            },
            defaultFont: line.defaultFont,
            glyphRuns: try line.glyphRuns.map
            {
                try translated($0, dx: dx, dy: dy)
            },
            marker: try line.marker.map
            {
                try translated($0, dx: dx, dy: dy)
            }
        )
    }

    func translated(
        _ stop: LayoutCaretStop,
        dx: Double,
        dy: Double
    ) throws -> LayoutCaretStop
    {
        LayoutCaretStop(
            utf16Offset: stop.utf16Offset,
            position: try point(
                x: stop.position.x + dx,
                y: stop.position.y + dy
            ),
            sourcePoint: stop.sourcePoint
        )
    }

    func translated(
        _ frame: LayoutRectangle,
        dx: Double,
        dy: Double
    ) throws -> LayoutRectangle
    {
        try rectangle(
            x: frame.origin.x + dx,
            y: frame.origin.y + dy,
            width: frame.size.width,
            height: frame.size.height
        )
    }
}
