extension EditableDocumentSnapshot
{
    func applying(
        _ edit: CanonicalDocumentEdit, result: AppliedCanonicalDocumentEdit,
        generation: SnapshotGeneration
    ) -> EditableDocumentSnapshot?
    {
        var intent: DocumentTypingIntent? = nil
        if let range = edit.typingRange, matchesInput(range)
        {
            guard let attributes = edit.insertedTypingAttributes ??
                typingAttributes(in: selection.range),
                  let inherited = InheritedTypingAttributes.attributes(
                      at: result.caret, in: result.document
                  )
            else
            {
                return nil
            }
            let candidate = DocumentTypingIntent(attributes: attributes)
            let automatic = DocumentTypingIntent(attributes: inherited)
            if typingIntent != nil || candidate != automatic
            {
                intent = candidate
            }
        }
        return EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(generation: generation,
                                       document: result.document),
            selection: .caret(at: result.caret.point), typingIntent: intent
        )
    }

    private func matchesInput(_ range: DocumentRange) -> Bool
    {
        let current = selection.range
        if current.isCollapsed
        {
            return range.start == current.start || range.end == current.start
        }
        return (range.start == current.start && range.end == current.end) ||
            (range.start == current.end && range.end == current.start)
    }
}
