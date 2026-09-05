struct DocumentHistoryCheckpoint: Equatable, Sendable
{
    let snapshot: EditableDocumentSnapshot
    let retainedUTF16Units: Int

    init?(_ snapshot: EditableDocumentSnapshot)
    {
        var count = 0
        for block in snapshot.snapshot.document.content.blocks
        {
            guard let editable = EditableSemanticBlock(block.block)
            else
            {
                return nil
            }
            for run in editable.runs
            {
                let (next, overflow) = count.addingReportingOverflow(
                    run.text.utf16.count
                )
                guard !overflow
                else
                {
                    return nil
                }
                count = next
            }
        }
        self.snapshot = snapshot
        retainedUTF16Units = count
    }
}
