import FundamentalRaster

extension SummitPresentationPreparation
{
    static func request(
        composer: PresentationComposer,
        raster: RasterSnapshot,
        surface: SummitPresentationSurface,
        intent: PresentationIntent,
        generation: UInt64
    ) -> PresentationRequest?
    {
        guard let lineage = composer.rasterLineage(of: raster),
              let specification = PresentationSpecificationIdentity(
                  caretWidth: surface.caretWidth,
                  adornmentPalette: surface.adornmentPalette,
                  maximumSelectionFragmentCount:
                    surface.maximumSelectionFragmentCount
              )
        else
        {
            return nil
        }
        return PresentationRequest(
            expectedRasterLineage: lineage,
            generation: generation,
            specification: specification,
            intent: intent
        )
    }
}
