package struct SemanticScopedRun: Equatable, Sendable
{
    package let text: String
    let traits: Set<SemanticInlineTrait>
    package let scopes: SemanticRunScopes

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
