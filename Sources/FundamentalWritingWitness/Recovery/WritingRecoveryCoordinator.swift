import Foundation
import FundamentalDocument

@MainActor
final class WritingRecoveryCoordinator
{
    weak var owner: WritingFileOwner?
    let store: WritingRecoveryStore
    let identifier: UUID
    var sequence: UInt64
    var observed: EditableDocumentSnapshot?
    var observedUnsaved = false
    var schedule = WritingRecoverySchedule()
    var pending: Task<Void, Never>?
    var stopped = false
    private(set) var lastError: String?
    var didFail: (@MainActor (String) -> Void)?

    init(
        owner: WritingFileOwner, store: WritingRecoveryStore,
        identifier: UUID = UUID(), sequence: UInt64 = 0
    )
    {
        self.owner = owner
        self.store = store
        self.identifier = identifier
        self.sequence = sequence
    }

    func capture(_ snapshot: EditableDocumentSnapshot) -> WritingRecoveryRecord?
    {
        guard !stopped, let owner, sequence < UInt64.max
        else
        {
            report(WritingRecoveryFailure.unavailableCheckpoint)
            return nil
        }
        guard owner.session.state == .editable(snapshot)
        else
        {
            report(WritingRecoveryFailure.invalidRecord)
            return nil
        }
        sequence += 1
        let source = owner.binding?.location.url ?? owner.recoverySource
        let name = owner.binding?.location.url.lastPathComponent ??
            owner.displayName
        let record = WritingRecoveryRecord(
            identifier: identifier, sequence: sequence, name: name,
            source: source, snapshot: snapshot,
            requiresRecovery: owner.session.isDirty
        )
        if record == nil
        {
            report(WritingRecoveryFailure.invalidRecord)
        }
        return record
    }

    func stop()
    {
        stopped = true
        cancelPending()
    }

    func report(_ error: Error)
    {
        let message = error.localizedDescription
        guard lastError != message
        else
        {
            return
        }
        lastError = message
        didFail?(message)
    }
}
