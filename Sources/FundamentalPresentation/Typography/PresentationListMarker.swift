package struct PresentationListMarker: Equatable, Sendable
{
    package let source: PresentationListMarkerSource
    package let baseline: PresentationPoint
    package let advance: Double
    package let inkBounds: PresentationRectangle

    package init?(
        source: PresentationListMarkerSource, baseline: PresentationPoint,
        advance: Double, inkBounds: PresentationRectangle
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
