package struct RasterInteractionText: Equatable, Sendable
{
    package let text: String
    package let defaultFont: RasterFontIdentity
    package let lineBounds: RasterRectangle
    package let baseline: RasterPoint
    package let sourceSlices: [RasterSourceSlice]
    package let firstCaretSite: RasterCaretSite
    package let remainingCaretSites: [RasterCaretSite]

    package var caretSites: [RasterCaretSite]
    {
        [firstCaretSite] + remainingCaretSites
    }
}
