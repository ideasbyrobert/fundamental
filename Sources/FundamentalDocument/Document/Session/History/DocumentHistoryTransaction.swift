struct DocumentHistoryTransaction: Equatable, Sendable
{
    let before: DocumentHistoryCheckpoint
    let after: DocumentHistoryCheckpoint
    let retainedUTF16Units: Int

    init?(
        before: DocumentHistoryCheckpoint,
        after: DocumentHistoryCheckpoint
    )
    {
        let previous = before.snapshot.snapshot
        let successor = after.snapshot.snapshot
        let (count, overflow) = before.retainedUTF16Units
            .addingReportingOverflow(after.retainedUTF16Units)
        guard previous.document.documentID == successor.document.documentID,
              DocumentRevision(after: previous.document.revision) ==
                  successor.document.revision,
              SnapshotGeneration(after: previous.generation) ==
                  successor.generation,
              !overflow
        else
        {
            return nil
        }
        self.before = before
        self.after = after
        retainedUTF16Units = count
    }
}
