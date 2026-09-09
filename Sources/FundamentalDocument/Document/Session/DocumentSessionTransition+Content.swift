extension DocumentSessionTransition
{
    static func preservingSelection(
        _ content: CanonicalDocumentContent,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        let previous = source.snapshot.document
        guard content != previous.content
        else
        {
            return .unchanged
        }
        guard let generation = SnapshotGeneration(
            after: source.snapshot.generation
        )
        else
        {
            return .refused(.generationExhausted)
        }
        guard let revision = DocumentRevision(after: previous.revision)
        else
        {
            return .refused(.invalidCommand)
        }
        let document = CanonicalDocument(
            documentID: previous.documentID, revision: revision,
            content: content
        )
        let range = source.selection.range
        func successor(_ point: DocumentPoint) -> DocumentPoint
        {
            DocumentPoint(
                documentID: document.documentID, revision: revision,
                blockID: point.blockID, utf16Offset: point.utf16Offset
            )
        }
        guard let range = DocumentRange(
            start: successor(range.start), end: successor(range.end)
        ),
              let editable = EditableDocumentSnapshot(
                  snapshot: DocumentSnapshot(
                      generation: generation, document: document
                  ),
                  selection: DocumentSelection(range: range)
              )
        else
        {
            return .refused(.invalidCommand)
        }
        return .applied(.editable(editable))
    }
}
