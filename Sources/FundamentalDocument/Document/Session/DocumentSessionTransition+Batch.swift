extension DocumentSessionTransition
{
    static func replace(
        _ batch: SemanticTextBatchReplacement,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        let previous = source.snapshot.document
        guard let applied = AppliedSemanticTextBatch(batch, in: previous)
        else
        {
            return .refused(.invalidCommand)
        }
        guard case let .changed(content, index, offset) = applied.result
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
        guard let revision = DocumentRevision(after: previous.revision),
              let position = DocumentUTF16Offset(offset)
        else
        {
            return .refused(.invalidCommand)
        }
        let document = CanonicalDocument(documentID: previous.documentID,
                                          revision: revision, content: content)
        let candidate = DocumentPoint(
            documentID: document.documentID, revision: revision,
            blockID: content.blocks[index].blockID, utf16Offset: position
        )
        guard let caret = ResolvedPostEditCaret(
            candidate: candidate, affinity: .following, in: document
        ),
              let editable = EditableDocumentSnapshot(
                  snapshot: DocumentSnapshot(generation: generation,
                                               document: document),
                  selection: .caret(at: caret.resolvedPoint.point)
              )
        else
        {
            return .refused(.invalidCommand)
        }
        return .applied(.editable(editable))
    }
}
