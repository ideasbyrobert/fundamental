struct RestoredDocumentHistoryCheckpoint: Equatable, Sendable
{
    let snapshot: EditableDocumentSnapshot

    init?(
        _ checkpoint: DocumentHistoryCheckpoint,
        in current: DocumentSnapshot
    )
    {
        let stored = checkpoint.snapshot
        guard stored.snapshot.document.documentID ==
                  current.document.documentID,
              let revision = DocumentRevision(after: current.document.revision),
              let generation = SnapshotGeneration(after: current.generation)
        else
        {
            return nil
        }
        let document = CanonicalDocument(
            documentID: current.document.documentID,
            revision: revision,
            content: stored.snapshot.document.content
        )
        let range = stored.selection.range
        let start = DocumentPoint(
            documentID: document.documentID,
            revision: revision,
            blockID: range.start.blockID,
            utf16Offset: range.start.utf16Offset
        )
        let end = DocumentPoint(
            documentID: document.documentID,
            revision: revision,
            blockID: range.end.blockID,
            utf16Offset: range.end.utf16Offset
        )
        guard let rebound = DocumentRange(start: start, end: end),
              let editable = EditableDocumentSnapshot(
                  snapshot: DocumentSnapshot(
                      generation: generation,
                      document: document
                  ),
                  selection: DocumentSelection(range: rebound)
              )
        else
        {
            return nil
        }
        snapshot = editable
    }
}
