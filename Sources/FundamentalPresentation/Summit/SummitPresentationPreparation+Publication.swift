import FundamentalRaster

extension SummitPresentationPreparation
{
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
}
