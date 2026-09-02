enum SemanticRunAttributes: Equatable, Sendable
{
    case direct(traits: Set<SemanticInlineTrait>)
    case scoped(
        traits: Set<SemanticInlineTrait>,
        scopes: SemanticRunScopes
    )
}
