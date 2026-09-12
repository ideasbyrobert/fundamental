import Foundation
import FundamentalDocument

extension WritingRecoveryCoordinator
{
    func prepareSave() -> WritingRecoveryRecord?
    {
        cancelPending()
        guard let owner, let projection = WritingProjection(owner.session.state)
        else
        {
            return nil
        }
        return capture(projection.snapshot)
    }

    func checkpoint(_ record: WritingRecoveryRecord) async
    {
        do
        {
            try await store.checkpoint(record)
        }
        catch
        {
            report(error)
        }
    }

    func saved(_ revision: UInt64) async
    {
        do
        {
            try await store.saved(identifier, revision: revision)
        }
        catch
        {
            report(error)
        }
    }

    func discard() async throws
    {
        cancelPending()
        try await store.discard(identifier)
        stop()
    }
}
