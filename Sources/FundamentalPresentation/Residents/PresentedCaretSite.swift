package struct PresentedCaretSite: Equatable, Sendable
{
    package let utf16Offset: Int
    package let position: PresentationPoint
    package let sourcePoint: PresentationTextPoint
}
