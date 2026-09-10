import FundamentalPresentation

extension MacReaderModel
{
    @discardableResult
    package func showCaret(
        at position: PresentationTextPosition
    ) -> Bool
    {
        publish(
            surface: currentSurface,
            intent: .caret(position)
        )
    }

    @discardableResult
    package func showSelection(
        anchor: PresentationTextPosition,
        focus: PresentationTextPosition
    ) -> Bool
    {
        if anchor == focus
        {
            return showCaret(at: focus)
        }
        guard let selection = PresentationTextSelection(
            anchor: anchor,
            focus: focus
        )
        else
        {
            return false
        }
        return publish(
            surface: currentSurface,
            intent: .selection(selection)
        )
    }
}
