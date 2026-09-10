import FundamentalRaster

@MainActor
package final class SummitPresentationPreparation
{
    let rasterPreparation: SummitRasterPreparation
    let composer: PresentationComposer
    let publisher: PresentationPublisher
    var currentRaster: RasterSnapshot
    var currentSurface: SummitPresentationSurface

    package init?(
        surface: SummitPresentationSurface,
        projection: PresentationDocumentProjection? = nil,
        intent: PresentationIntent = .document,
        admitting: (PresentationSnapshot) -> Bool
    )
    {
        guard let rasterPreparation = Self.rasterPreparation(
            projection: projection, initialMeasure: surface.readableMeasure
        ),
              let raster = Self.raster(
                  rasterPreparation,
                  surface: surface,
                  generation: 1
              )
        else
        {
            return nil
        }
        let composer = PresentationComposer()
        let lease = PresentationAttemptLease(generation: 1)
        guard let request = Self.request(
            composer: composer,
            raster: raster,
            surface: surface,
            intent: intent,
            generation: lease.generation
        ),
              let snapshot = composer.present(
                  raster,
                  request: request
              ),
              admitting(snapshot),
              let publisher = PresentationPublisher(
                  current: snapshot,
                  latestAttempt: lease
              )
        else
        {
            return nil
        }
        self.rasterPreparation = rasterPreparation
        self.composer = composer
        self.publisher = publisher
        currentRaster = raster
        currentSurface = surface
    }
}
