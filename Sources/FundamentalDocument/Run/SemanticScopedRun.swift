struct SemanticScopedRun: Equatable, Sendable
{
    let text: String
    let traits: Set<SemanticInlineTrait>
    let scopes: SemanticRunScopes

    init(
        text: String,
        traits: Set<SemanticInlineTrait> = [],
        scopes: SemanticRunScopes
    )
    {
        self.text = text
        self.traits = traits
        self.scopes = scopes
    }
}
