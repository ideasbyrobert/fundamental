package struct PresentationCaretAdornment: Equatable, Sendable
{
    package let position: PresentationTextPosition
    package let sitePosition: PresentationPoint
    package let lineBounds: PresentationRectangle
    package let logicalBounds: PresentationRectangle
    package let color: PresentationColor
}
