import AppKit
import FundamentalPresentation

@MainActor
package struct MacAppearancePalette
{
    package let appearance: PresentationAppearance
    package let document: PresentationPalette
    package let adornments: PresentationAdornmentPalette

    package init?(
        native: NSAppearance,
        display: MacDisplayIdentity,
        increasedContrast: Bool
    )
    {
        let luminosity: PresentationLuminosity
        let match = native.bestMatch(from: [.aqua, .darkAqua])
        switch match
        {
        case .aqua:
            luminosity = .light
        case .darkAqua:
            luminosity = .dark
        default:
            return nil
        }
        let contrast: PresentationContrast = increasedContrast
            ? .increased
            : .standard
        appearance = PresentationAppearance(
            luminosity: luminosity,
            contrast: contrast
        )
        guard let colors = Self.colors(
            native: native,
            display: display
        ),
              let document = PresentationPalette(
                  documentBackground: colors[0],
                  tableBackground: colors[1],
                  headerBackground: colors[2],
                  rule: colors[3],
                  text: colors[4],
                  decoration: colors[5]
              ),
              let adornments = PresentationAdornmentPalette(
                  caret: colors[6],
                  selection: colors[7]
              )
        else
        {
            return nil
        }
        self.document = document
        self.adornments = adornments
    }

    private static func colors(
        native: NSAppearance,
        display: MacDisplayIdentity
    ) -> [PresentationColor]?
    {
        var resolved: [PresentationColor] = []
        native.performAsCurrentDrawingAppearance
        {
            let dynamic = [
                NSColor.textBackgroundColor,
                NSColor.controlBackgroundColor,
                NSColor.underPageBackgroundColor,
                NSColor.separatorColor,
                NSColor.labelColor,
                NSColor.secondaryLabelColor,
                NSColor.controlAccentColor,
                NSColor.selectedTextBackgroundColor
            ]
            resolved = dynamic.compactMap
            {
                color($0, display: display)
            }
        }
        return resolved.count == 8 ? resolved : nil
    }

    private static func color(
        _ native: NSColor,
        display: MacDisplayIdentity
    ) -> PresentationColor?
    {
        guard let converted = native.usingColorSpace(
            display.colorSpace.native
        ),
              let components = converted.cgColor.components,
              components.count
                == display.presentation.componentCount + 1
        else
        {
            return nil
        }
        return PresentationColor(
            colorSpace: display.presentation,
            components: components.dropLast().map(Double.init),
            alpha: Double(components[components.count - 1])
        )
    }
}
