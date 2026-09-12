package struct SemanticTextBatchReplacement: Equatable, Sendable
{
    let substitutions: [SemanticTextSubstitution]

    package init?(_ substitutions: [SemanticTextSubstitution])
    {
        guard !substitutions.isEmpty
        else
        {
            return nil
        }
        self.substitutions = substitutions
    }
}
