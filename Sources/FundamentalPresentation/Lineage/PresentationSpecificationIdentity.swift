package struct PresentationSpecificationIdentity:
    Equatable,
    Sendable
{
    package let caretWidth: Double
    package let adornmentPalette: PresentationAdornmentPalette
    package let maximumSelectionFragmentCount: Int

    package init?(
        caretWidth: Double,
        adornmentPalette: PresentationAdornmentPalette,
        maximumSelectionFragmentCount: Int
    )
    {
        guard caretWidth.isFinite,
              caretWidth > 0,
              maximumSelectionFragmentCount > 0
        else
        {
            return nil
        }
        self.caretWidth = caretWidth
        self.adornmentPalette = adornmentPalette
        self.maximumSelectionFragmentCount = maximumSelectionFragmentCount
    }
}
