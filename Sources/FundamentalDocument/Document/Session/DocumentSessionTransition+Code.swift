extension DocumentSessionTransition
{
    static func convertCode(
        _ conversion: SemanticCodeConversion,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        let previous = source.snapshot.document
        guard let applied = AppliedSemanticCodeConversion(
            conversion, in: previous
        )
        else
        {
            return .refused(.invalidCommand)
        }
        guard applied.content != previous.content
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
            content: applied.content
        )
        guard let selection = applied.selection(
            source.selection, from: previous, to: document
        ),
              let editable = EditableDocumentSnapshot(
                  snapshot: DocumentSnapshot(
                      generation: generation, document: document
                  ),
                  selection: selection
              )
        else
        {
            return .refused(.invalidCommand)
        }
        return .applied(.editable(editable))
    }
}
