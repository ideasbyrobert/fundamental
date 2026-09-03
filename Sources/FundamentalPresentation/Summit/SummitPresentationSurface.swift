package struct SummitPresentationSurface: Equatable, Sendable
{
    package let readableMeasure: Double
    package let visibleOriginY: Double
    package let visibleHeight: Double
    package let overscanExtent: Double
    package let maximumResidentCount: Int
    package let backingScale: Double
    package let appearance: PresentationAppearance
    package let colorSpace: PresentationColorSpaceIdentity
    package let palette: PresentationPalette
    package let adornmentPalette: PresentationAdornmentPalette
    package let caretWidth: Double
    package let maximumSelectionFragmentCount: Int

    package init?(
        readableMeasure: Double,
        visibleOriginY: Double,
        visibleHeight: Double,
        overscanExtent: Double,
        maximumResidentCount: Int,
        backingScale: Double,
        appearance: PresentationAppearance,
        colorSpace: PresentationColorSpaceIdentity,
        palette: PresentationPalette,
        adornmentPalette: PresentationAdornmentPalette,
        caretWidth: Double,
        maximumSelectionFragmentCount: Int
    )
    {
        guard readableMeasure.isFinite,
              readableMeasure > 0,
              visibleOriginY.isFinite,
              visibleOriginY >= 0,
              visibleHeight.isFinite,
              visibleHeight > 0,
              overscanExtent.isFinite,
              overscanExtent >= 0,
              maximumResidentCount > 0,
              backingScale.isFinite,
              backingScale > 0,
              palette.colorSpace == colorSpace,
              adornmentPalette.colorSpace == colorSpace,
              caretWidth.isFinite,
              caretWidth > 0,
              maximumSelectionFragmentCount > 0
        else
        {
            return nil
        }
        self.readableMeasure = readableMeasure
        self.visibleOriginY = visibleOriginY
        self.visibleHeight = visibleHeight
        self.overscanExtent = overscanExtent
        self.maximumResidentCount = maximumResidentCount
        self.backingScale = backingScale
        self.appearance = appearance
        self.colorSpace = colorSpace
        self.palette = palette
        self.adornmentPalette = adornmentPalette
        self.caretWidth = caretWidth
        self.maximumSelectionFragmentCount =
            maximumSelectionFragmentCount
    }
}
