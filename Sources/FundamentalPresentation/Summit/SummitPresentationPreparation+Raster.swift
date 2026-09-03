import FundamentalRaster

extension SummitPresentationPreparation
{
    static func raster(
        _ preparation: SummitRasterPreparation,
        surface: SummitPresentationSurface,
        generation: UInt64
    ) -> RasterSnapshot?
    {
        guard let colorSpace = RasterColorSpaceIdentity(
            name: surface.colorSpace.name,
            profile: surface.colorSpace.profile,
            componentCount: surface.colorSpace.componentCount
        ),
              let palette = rasterPalette(
                  surface.palette,
                  colorSpace: colorSpace
              ),
              let capacities = RasterCapacities(
                  marks: 100_000,
                  glyphs: 100_000,
                  fills: 20_000,
                  sourceSlices: 200_000,
                  caretSites: 100_000,
                  interactionRegions: surface.maximumResidentCount,
                  fontVariations: 1_000,
                  residentUTF16Units: 1_000_000,
                  pixelArea: 32_000_000
              )
        else
        {
            return nil
        }
        return preparation.raster(
            generation: generation,
            readableMeasure: surface.readableMeasure,
            visibleOriginY: surface.visibleOriginY,
            visibleHeight: surface.visibleHeight,
            overscanExtent: surface.overscanExtent,
            maximumResidentCount: surface.maximumResidentCount,
            backingScale: surface.backingScale,
            appearance: rasterAppearance(surface.appearance),
            colorSpace: colorSpace,
            palette: palette,
            capacities: capacities
        )
    }

    private static func rasterAppearance(
        _ value: PresentationAppearance
    ) -> RasterAppearance
    {
        let luminosity: RasterLuminosity
        switch value.luminosity
        {
        case .light:
            luminosity = .light
        case .dark:
            luminosity = .dark
        }
        let contrast: RasterContrast
        switch value.contrast
        {
        case .standard:
            contrast = .standard
        case .increased:
            contrast = .increased
        }
        return RasterAppearance(
            luminosity: luminosity,
            contrast: contrast
        )
    }

    private static func rasterPalette(
        _ value: PresentationPalette,
        colorSpace: RasterColorSpaceIdentity
    ) -> RasterPalette?
    {
        guard let document = rasterColor(
            value.documentBackground,
            colorSpace: colorSpace
        ),
              let table = rasterColor(
                  value.tableBackground,
                  colorSpace: colorSpace
              ),
              let header = rasterColor(
                  value.headerBackground,
                  colorSpace: colorSpace
              ),
              let rule = rasterColor(
                  value.rule,
                  colorSpace: colorSpace
              ),
              let text = rasterColor(
                  value.text,
                  colorSpace: colorSpace
              ),
              let decoration = rasterColor(
                  value.decoration,
                  colorSpace: colorSpace
              )
        else
        {
            return nil
        }
        return RasterPalette(
            documentBackground: document,
            tableBackground: table,
            headerBackground: header,
            rule: rule,
            text: text,
            decoration: decoration
        )
    }

    private static func rasterColor(
        _ value: PresentationColor,
        colorSpace: RasterColorSpaceIdentity
    ) -> RasterColor?
    {
        RasterColor(
            colorSpace: colorSpace,
            components: value.components,
            alpha: value.alpha
        )
    }
}
