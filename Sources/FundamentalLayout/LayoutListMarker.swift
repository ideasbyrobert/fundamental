package struct LayoutListMarker: Equatable, Sendable
{
    package let source: LayoutListMarkerSource
    package let baseline: LayoutPoint
    package let advance: Double
    package let inkBounds: LayoutRectangle
    package let firstGlyphRun: LayoutGlyphRun
    package let remainingGlyphRuns: [LayoutGlyphRun]

    package var glyphRuns: [LayoutGlyphRun]
    {
        [firstGlyphRun] + remainingGlyphRuns
    }
}
