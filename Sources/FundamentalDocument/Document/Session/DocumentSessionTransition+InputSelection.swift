extension DocumentSessionTransition
{
    static func inputSelection(
        _ transaction: DocumentInputTransaction,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        guard let proposed = EditableDocumentSnapshot(
            snapshot: source.snapshot, selection: transaction.selection,
            typingIntent: transaction.typingIntent
        )
        else
        {
            return .refused(.invalidCommand)
        }
        guard proposed != source
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
        guard let completed = EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(generation: generation,
                                       document: source.snapshot.document),
            selection: transaction.selection,
            typingIntent: transaction.typingIntent
        )
        else
        {
            return .refused(.invalidCommand)
        }
        return .applied(.editable(completed))
    }
}
