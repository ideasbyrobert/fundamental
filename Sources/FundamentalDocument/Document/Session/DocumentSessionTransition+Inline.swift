extension DocumentSessionTransition
{
    static func inline(
        _ change: SemanticInlineTraitChange,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        guard let applied = AppliedSemanticInlineTraitChange(
            change, in: source.snapshot.document
        )
        else
        {
            return .refused(.invalidCommand)
        }
        return preservingSelection(applied.content, in: source)
    }
}
