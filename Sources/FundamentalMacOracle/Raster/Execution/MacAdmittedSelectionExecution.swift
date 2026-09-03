import FundamentalPresentation

@MainActor
struct MacAdmittedSelectionExecution
{
    let source: PresentationSelectionAdornment
    let color: MacAdmittedColor
    let firstFragment: MacAdmittedSelectionFragment
    let remainingFragments: [MacAdmittedSelectionFragment]

    var fragments: [MacAdmittedSelectionFragment]
    {
        [firstFragment] + remainingFragments
    }
}
