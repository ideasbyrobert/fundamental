struct WritingRecoveryAdmission
{
    var revision: UInt64?
    var sequence: UInt64 = 0
    var savedRevision: UInt64?
    var discarded = false

    mutating func admit(_ record: WritingRecoveryRecord) -> Bool
    {
        guard !discarded,
              savedRevision.map({ record.revision > $0 }) ?? true
        else
        {
            return false
        }
        if let revision
        {
            guard record.revision > revision ||
                (record.revision == revision && record.sequence > sequence)
            else
            {
                return false
            }
        }
        revision = record.revision
        sequence = record.sequence
        return true
    }

    mutating func saved(_ revision: UInt64)
    {
        savedRevision = max(savedRevision ?? revision, revision)
    }
}
