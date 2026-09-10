package struct RasterListMarker: Equatable, Sendable
{
    package let source: RasterListMarkerSource
    package let baseline: RasterPoint
    package let advance: Double
    package let inkBounds: RasterRectangle

    package init?(
        source: RasterListMarkerSource, baseline: RasterPoint,
        advance: Double, inkBounds: RasterRectangle
    )
    {
        guard advance.isFinite, advance > 0,
              inkBounds.size.width > 0, inkBounds.size.height > 0
        else
        {
            return nil
        }
        self.source = source
        self.baseline = baseline
        self.advance = advance
        self.inkBounds = inkBounds
    }
}
