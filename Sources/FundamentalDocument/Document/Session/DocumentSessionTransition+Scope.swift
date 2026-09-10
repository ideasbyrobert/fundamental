extension DocumentSessionTransition
{
    static func scope(
        _ change: SemanticRunScopeChange,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        guard let applied = AppliedSemanticRunScopeChange(
            change, in: source.snapshot.document
        )
        else
        {
            return .refused(.invalidCommand)
        }
        return preservingSelection(applied.content, in: source)
    }

    static func typingScope(
        _ assignment: SemanticRunScopeAssignment,
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
}
