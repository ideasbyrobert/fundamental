struct AppliedSemanticRunScopeChange: Equatable, Sendable
{
    let content: CanonicalDocumentContent

    init?(_ change: SemanticRunScopeChange, in source: CanonicalDocument)
    {
        guard let applied = AppliedSemanticRunFormatting(
            change.range, in: source, assigning: change.assignment.applying(to:)
        )
        else
        {
            return nil
        }
        content = applied.content
    }
}
