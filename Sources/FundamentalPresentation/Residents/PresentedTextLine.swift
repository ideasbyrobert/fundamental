package struct PresentedTextLine: Equatable, Sendable
{
    package let text: String
    package let defaultFont: PresentationFontIdentity
    package let lineBounds: PresentationRectangle
    package let baseline: PresentationPoint
    package let sourceSlices: [PresentationSourceSlice]
    package let firstCaretSite: PresentedCaretSite
    package let remainingCaretSites: [PresentedCaretSite]

    package var caretSites: [PresentedCaretSite]
    {
        [firstCaretSite] + remainingCaretSites
    }
}
