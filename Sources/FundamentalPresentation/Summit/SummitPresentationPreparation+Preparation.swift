import FundamentalRaster

extension SummitPresentationPreparation
{
    package func prepare(
        surface: SummitPresentationSurface,
        intent: PresentationIntent,
        lease: PresentationAttemptLease
    ) -> SummitPresentationAttempt?
    {
        let raster: RasterSnapshot
        if surface == currentSurface
        {
            raster = currentRaster
        }
        else
        {
            guard let prepared = Self.raster(
                rasterPreparation,
                surface: surface,
                generation: lease.generation
            )
            else
            {
                return nil
            }
            raster = prepared
        }
        guard let request = Self.request(
            composer: composer,
            raster: raster,
            surface: surface,
            intent: intent,
            generation: lease.generation
        ),
              let snapshot = composer.present(
                  raster,
                  request: request,
                  reusing: currentSnapshot
              )
        else
        {
            return nil
        }
        return SummitPresentationAttempt(
            snapshot: snapshot,
            lease: lease,
            raster: raster,
            surface: surface
        )
    }
}
