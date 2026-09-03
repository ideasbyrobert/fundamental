package struct PresentationSelectionAdornment: Equatable, Sendable
{
    package let anchor: PresentationTextPosition
    package let focus: PresentationTextPosition
    package let color: PresentationColor
    package let text: String
    package let sourceSlices: [PresentationSourceSlice]
    package let firstFragment: PresentationSelectionFragment
    package let remainingFragments: [PresentationSelectionFragment]

    package var fragments: [PresentationSelectionFragment]
    {
        [firstFragment] + remainingFragments
    }
}
