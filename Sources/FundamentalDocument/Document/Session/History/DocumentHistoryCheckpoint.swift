struct DocumentHistoryCheckpoint: Equatable, Sendable
{
    let snapshot: EditableDocumentSnapshot
    let contentRevision: DocumentRevision
    let retainedUTF16Units: Int

    init?(
        _ snapshot: EditableDocumentSnapshot,
        contentRevision: DocumentRevision? = nil
    )
    {
        let revision = contentRevision ?? snapshot.snapshot.document.revision
        guard revision <= snapshot.snapshot.document.revision
        else
        {
            return nil
        }
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
        self.contentRevision = revision
        retainedUTF16Units = count
    }
}
