import Foundation
import FundamentalDocument

extension WritingRecoveryCoordinator
{
    func observe(_ projection: WritingProjection)
    {
        guard !stopped, let owner,
              owner.session.state == .editable(projection.snapshot)
        else
        {
            return
        }
        guard owner.session.isDirty
        else
        {
            let previouslyUnsaved = observedUnsaved
            observedUnsaved = false
            observed = projection.snapshot
            cancelPending()
            if previouslyUnsaved, let record = capture(projection.snapshot)
            {
                pending = Task { await checkpoint(record) }
            }
            return
        }
        guard observed != projection.snapshot
        else
        {
            return
        }
        observed = projection.snapshot
        observedUnsaved = true
        if projection.text.isEmpty, !owner.session.canUndo,
           owner.binding == nil, owner.recoverySource == nil
        {
            return
        }
        schedule.changed(at: .now)
        armTimer()
    }

    func armTimer()
    {
        pending?.cancel()
        guard let deadline = schedule.deadline
        else
        {
            return
        }
        pending = Task
        {
            [weak self] in
            do
            {
                try await ContinuousClock().sleep(until: deadline)
            }
            catch
            {
                return
            }
            guard let self, !Task.isCancelled, !stopped,
                  let snapshot = observed,
                  let record = capture(snapshot)
            else
            {
                return
            }
            pending = nil
            schedule.reset()
            await checkpoint(record)
        }
    }

    func cancelPending()
    {
        pending?.cancel()
        pending = nil
        schedule.reset()
    }
}
