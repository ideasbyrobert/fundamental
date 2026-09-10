extension DocumentSessionTransition
{
    static func typing(
        _ assignment: SemanticInlineTraitAssignment,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        guard let inherited = source.typingAttributes(
            in: source.selection.range
        )
        else
        {
            return .refused(.invalidCommand)
        }
        return typing(assignment.applying(to: inherited), in: source)
    }

    static func typing(
        _ attributes: SemanticRunAttributes,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        guard source.selection.range.isCollapsed
        else
        {
            return .refused(.invalidCommand)
        }
        let intent = DocumentTypingIntent(attributes: attributes)
        guard intent != source.typingIntent
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
        guard let editable = EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(
                generation: generation, document: source.snapshot.document
            ), selection: source.selection, typingIntent: intent
        )
        else
        {
            return .refused(.invalidCommand)
        }
        return .applied(.editable(editable))
    }
}
