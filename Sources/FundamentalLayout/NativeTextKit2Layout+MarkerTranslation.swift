extension NativeTextKit2Layout
{
    func translated(
        _ marker: LayoutListMarker,
        dx: Double,
        dy: Double
    ) throws -> LayoutListMarker
    {
        LayoutListMarker(
            source: marker.source,
            baseline: try point(
                x: marker.baseline.x + dx, y: marker.baseline.y + dy
            ),
            advance: marker.advance,
            inkBounds: try translated(marker.inkBounds, dx: dx, dy: dy),
            firstGlyphRun: try translated(
                marker.firstGlyphRun, dx: dx, dy: dy
            ),
            remainingGlyphRuns: try marker.remainingGlyphRuns.map
            {
                try translated($0, dx: dx, dy: dy)
            }
        )
    }
}
