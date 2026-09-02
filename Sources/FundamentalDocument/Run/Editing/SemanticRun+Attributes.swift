extension SemanticRun
{
    init(
        text: String,
        attributes: SemanticRunAttributes
    )
    {
        switch attributes
        {
        case let .direct(traits):
            self = .direct(SemanticDirectRun(
                text: text,
                traits: traits
            ))
        case let .scoped(traits, scopes):
            self = .scoped(SemanticScopedRun(
                text: text,
                traits: traits,
                scopes: scopes
            ))
        }
    }

    var attributes: SemanticRunAttributes
    {
        switch self
        {
        case let .direct(run):
            .direct(traits: run.traits)
        case let .scoped(run):
            .scoped(
                traits: run.traits,
                scopes: run.scopes
            )
        }
    }
}
