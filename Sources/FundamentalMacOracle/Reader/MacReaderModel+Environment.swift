import AppKit
import FundamentalPresentation

extension MacReaderModel
{
    @discardableResult
    package func update(
        viewportWidth: Double,
        viewportHeight: Double,
        visibleOriginY: Double,
        screen: NSScreen,
        appearance: NSAppearance,
        increasedContrast: Bool = false
    ) -> Bool
    {
        guard let environment = MacReaderEnvironment(
            screen: screen,
            appearance: appearance,
            increasedContrast: increasedContrast
        )
        else
        {
            return false
        }
        guard let surface = environment.surface(
            viewportWidth: viewportWidth,
            visibleOriginY: max(0, visibleOriginY),
            visibleHeight: viewportHeight
        )
        else
        {
            return false
        }
        if surface == currentSurface
        {
            return true
        }
        return publish(surface: surface, intent: .document)
    }
}
