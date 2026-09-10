import FundamentalPresentation

extension MacRasterExecutor
{
    func admit(
        _ caret: PresentationCaretAdornment,
        colorSpace: MacAdmittedColorSpace
    ) -> MacAdmittedCaretExecution?
    {
        guard let color = MacAdmittedColor(
            caret.color,
            colorSpace: colorSpace
        )
        else
        {
            return nil
        }
        return MacAdmittedCaretExecution(
            source: caret,
            color: color,
            logicalBounds: Self.rectangle(caret.logicalBounds)
        )
    }

    func admit(
        _ selection: PresentationSelectionAdornment,
        colorSpace: MacAdmittedColorSpace
    ) -> MacAdmittedSelectionExecution?
    {
        guard let color = MacAdmittedColor(
            selection.color,
            colorSpace: colorSpace
        )
        else
        {
            return nil
        }
        let fragments = selection.fragments.map
        {
            MacAdmittedSelectionFragment(
                residentID: $0.residentID,
                logicalBounds: Self.rectangle($0.logicalBounds)
            )
        }
        guard let first = fragments.first
        else
        {
            return nil
        }
        return MacAdmittedSelectionExecution(
            source: selection,
            color: color,
            firstFragment: first,
            remainingFragments: Array(fragments.dropFirst())
        )
    }
}
