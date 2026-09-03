import FundamentalRaster

@MainActor
package final class SummitPresentationPreparation
{
    private let rasterPreparation: SummitRasterPreparation
    private let composer: PresentationComposer
    private let publisher: PresentationPublisher
    private var currentRaster: RasterSnapshot
    private var currentSurface: SummitPresentationSurface

    package init?(
        surface: SummitPresentationSurface,
        intent: PresentationIntent = .document,
        admitting: (PresentationSnapshot) -> Bool
    )
    {
        guard let rasterPreparation = SummitRasterPreparation(),
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

    package var currentSnapshot: PresentationSnapshot
    {
        publisher.currentSnapshot
    }

    package var layoutExecutionCount: Int
    {
        rasterPreparation.layoutExecutionCount
    }

    package func reserveAttempt() -> PresentationAttemptLease?
    {
        publisher.reserveAttempt()
    }

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

    @discardableResult
    package func publish(
        _ attempt: SummitPresentationAttempt
    ) -> Bool
    {
        guard publisher.publish(
            attempt.snapshot,
            lease: attempt.lease
        )
        else
        {
            return false
        }
        currentRaster = attempt.raster
        currentSurface = attempt.surface
        return true
    }

    private static func request(
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
