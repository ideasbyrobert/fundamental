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
              let editable = source.applying(edit, result: applied,
                                            generation: generation)
        else
        {
            return .refused(.invalidCommand)
        }
        return .applied(.editable(editable))
    }

}
