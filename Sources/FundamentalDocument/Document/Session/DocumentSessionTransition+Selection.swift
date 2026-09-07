extension DocumentSessionTransition
{
    static func select(
        _ selection: DocumentSelection,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        guard ResolvedDocumentRange(
            selection.range,
            in: source.snapshot.document
        ) != nil
        else
        {
            return .refused(.invalidCommand)
        }
        if selection == source.selection
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
        guard let editable = EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(
                generation: generation,
                document: source.snapshot.document
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
