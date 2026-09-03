import AppKit
import FundamentalPresentation

@MainActor
package struct MacReaderEnvironment
{
    package let display: MacDisplayIdentity
    package let palette: MacAppearancePalette

    package init?(
        screen: NSScreen,
        appearance: NSAppearance,
        increasedContrast: Bool
    )
    {
        guard let display = MacDisplayIdentity(screen),
              let palette = MacAppearancePalette(
                  native: appearance,
                  display: display,
                  increasedContrast: increasedContrast
              )
        else
        {
            return nil
        }
        self.display = display
        self.palette = palette
    }

    init(
        display: MacDisplayIdentity,
        palette: MacAppearancePalette
    )
    {
        self.display = display
        self.palette = palette
    }

    package func surface(
        viewportWidth: Double,
        visibleOriginY: Double,
        visibleHeight: Double
    ) -> SummitPresentationSurface?
    {
        let measure = min(720, viewportWidth - 64)
        return SummitPresentationSurface(
            readableMeasure: measure,
            visibleOriginY: visibleOriginY,
            visibleHeight: visibleHeight,
            overscanExtent: 240,
            maximumResidentCount: 192,
            backingScale: display.backingScale,
            appearance: palette.appearance,
            colorSpace: display.presentation,
            palette: palette.document,
            adornmentPalette: palette.adornments,
            caretWidth: 1,
            maximumSelectionFragmentCount: 192
        )
    }
}
