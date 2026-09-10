extension DocumentSessionTransition
{
    static func input(
        _ transaction: DocumentInputTransaction,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        guard let edit = transaction.edit
        else
        {
            return inputSelection(transaction, in: source)
        }
        let result = Self.apply(edit, to: source)
        guard case let .applied(.editable(edited)) = result
        else
        {
            return result
        }
        guard let completed = EditableDocumentSnapshot(
            snapshot: edited.snapshot, selection: transaction.selection,
            typingIntent: transaction.typingIntent
        )
        else
        {
            return .refused(.invalidCommand)
        }
        return .applied(.editable(completed))
    }
}
