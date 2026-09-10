package struct RasterInteractionText: Equatable, Sendable
{
    package let text: String
    package let defaultFont: RasterFontIdentity
    package let lineBounds: RasterRectangle
    package let baseline: RasterPoint
    package let marker: RasterListMarker?
    package let sourceSlices: [RasterSourceSlice]
    package let firstCaretSite: RasterCaretSite
    package let remainingCaretSites: [RasterCaretSite]

    init(
        text: String, defaultFont: RasterFontIdentity,
        lineBounds: RasterRectangle, baseline: RasterPoint,
        marker: RasterListMarker? = nil, sourceSlices: [RasterSourceSlice],
        firstCaretSite: RasterCaretSite,
        remainingCaretSites: [RasterCaretSite]
    )
    {
        self.text = text
        self.defaultFont = defaultFont
        self.lineBounds = lineBounds
        self.baseline = baseline
        self.marker = marker
        self.sourceSlices = sourceSlices
        self.firstCaretSite = firstCaretSite
        self.remainingCaretSites = remainingCaretSites
    }

    package var caretSites: [RasterCaretSite]
    {
        [firstCaretSite] + remainingCaretSites
    }
}
