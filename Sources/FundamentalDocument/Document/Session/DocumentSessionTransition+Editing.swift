extension DocumentSessionTransition
{
    static func apply(
        _ edit: CanonicalDocumentEdit,
        to source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        guard let generation = SnapshotGeneration(
            after: source.snapshot.generation
        )
        else
        {
            return .refused(.generationExhausted)
        }
        guard let applied = AppliedCanonicalDocumentEdit(
            edit,
            in: source.snapshot.document
        ),
              let editable = EditableDocumentSnapshot(
                  snapshot: DocumentSnapshot(
                      generation: generation,
                      document: applied.document
                  ),
                  selection: .caret(at: applied.caret.point)
              )
        else
        {
            return .refused(.invalidCommand)
        }
        return .applied(.editable(editable))
    }

}
