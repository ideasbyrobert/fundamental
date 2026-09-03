package struct PresentationAdornmentPalette: Equatable, Sendable
{
    package let caret: PresentationColor
    package let selection: PresentationColor

    package init?(
        caret: PresentationColor,
        selection: PresentationColor
    )
    {
        guard caret.colorSpace == selection.colorSpace
        else
        {
            return nil
        }
        self.caret = caret
        self.selection = selection
    }

    package var colorSpace: PresentationColorSpaceIdentity
    {
        caret.colorSpace
    }
}
