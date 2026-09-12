import FundamentalDocument

extension WritingFileOwner
{
    static func recover(
        _ record: WritingRecoveryRecord, store: WritingRecoveryStore
    ) -> WritingFileOwner
    {
        let owner = WritingFileOwner(session: DocumentSession(
            state: .editable(record.snapshot)
        ))
        owner.displayName = record.name
        owner.isRecovered = true
        owner.recoverySource = record.source
        owner.recovery = WritingRecoveryCoordinator(
            owner: owner, store: store, identifier: record.identifier,
            sequence: record.sequence
        )
        return owner
    }
}
