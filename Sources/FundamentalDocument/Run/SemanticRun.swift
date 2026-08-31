enum SemanticRun: Codable, Equatable, Sendable
{
    case direct(SemanticDirectRun)
    case scoped(SemanticScopedRun)

    init(
        text: String,
        traits: Set<SemanticInlineTrait> = []
    )
    {
        self = .direct(
            SemanticDirectRun(
                text: text,
                traits: traits
            )
        )
    }

    var text: String
    {
        switch self
        {
        case let .direct(run):
            run.text
        case let .scoped(run):
            run.text
        }
    }

    var traits: Set<SemanticInlineTrait>
    {
        switch self
        {
        case let .direct(run):
            run.traits
        case let .scoped(run):
            run.traits
        }
    }
}
