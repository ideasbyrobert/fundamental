import FundamentalRaster

extension PresentationComposer
{
    static func appearance(
        _ value: RasterAppearance
    ) -> PresentationAppearance
    {
        let luminosity: PresentationLuminosity
        switch value.luminosity
        {
        case .light:
            luminosity = .light
        case .dark:
            luminosity = .dark
        }
        let contrast: PresentationContrast
        switch value.contrast
        {
        case .standard:
            contrast = .standard
        case .increased:
            contrast = .increased
        }
        return PresentationAppearance(
            luminosity: luminosity,
            contrast: contrast
        )
    }

    static func colorSpace(
        _ value: RasterColorSpaceIdentity
    ) -> PresentationColorSpaceIdentity?
    {
        PresentationColorSpaceIdentity(
            name: value.name,
            profile: value.profile,
            componentCount: value.componentCount
        )
    }

    static func color(
        _ value: RasterColor
    ) -> PresentationColor?
    {
        guard let space = colorSpace(value.colorSpace)
        else
        {
            return nil
        }
        return PresentationColor(
            colorSpace: space,
            components: value.components,
            alpha: value.alpha
        )
    }

    static func palette(
        _ value: RasterPalette
    ) -> PresentationPalette?
    {
        guard let document = color(value.documentBackground),
              let table = color(value.tableBackground),
              let header = color(value.headerBackground),
              let rule = color(value.rule),
              let text = color(value.text),
              let decoration = color(value.decoration)
        else
        {
            return nil
        }
        return PresentationPalette(
            documentBackground: document,
            tableBackground: table,
            headerBackground: header,
            rule: rule,
            text: text,
            decoration: decoration
        )
    }
}
