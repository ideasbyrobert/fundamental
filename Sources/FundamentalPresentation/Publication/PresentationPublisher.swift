@MainActor
package final class PresentationPublisher
{
    private var current: PresentationSnapshot
    package private(set) var latestAttempt: PresentationAttemptLease

    package init?(
        current: PresentationSnapshot,
        latestAttempt: PresentationAttemptLease
    )
    {
        guard current.lineage.generation <= latestAttempt.generation
        else
        {
            return nil
        }
        self.current = current
        self.latestAttempt = latestAttempt
    }

    package var currentSnapshot: PresentationSnapshot
    {
        current
    }

    package func reserveAttempt() -> PresentationAttemptLease?
    {
        let (generation, overflow) = latestAttempt.generation
            .addingReportingOverflow(1)
        guard !overflow
        else
        {
            return nil
        }
        let lease = PresentationAttemptLease(generation: generation)
        latestAttempt = lease
        return lease
    }

    @discardableResult
    package func publish(
        _ snapshot: PresentationSnapshot,
        lease: PresentationAttemptLease
    ) -> Bool
    {
        guard lease == latestAttempt,
              snapshot.lineage.generation == lease.generation
        else
        {
            return false
        }
        current = snapshot
        return true
    }
}
