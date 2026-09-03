package struct PresentationTextSelection: Equatable, Sendable
{
    package let anchor: PresentationTextPosition
    package let focus: PresentationTextPosition

    package init?(
        anchor: PresentationTextPosition,
        focus: PresentationTextPosition
    )
    {
        guard anchor.sourcePoint != focus.sourcePoint
        else
        {
            return nil
        }
        self.anchor = anchor
        self.focus = focus
    }
}
