package enum ProjectedRun: Equatable, Sendable
{
    case direct(
        source: ProjectedTextSource,
        text: String,
        traits: Set<ProjectedInlineTrait>
    )
    case scoped(
        source: ProjectedTextSource,
        text: String,
        traits: Set<ProjectedInlineTrait>,
        scope: ProjectedRunScope
    )

    package var source: ProjectedTextSource
    {
        switch self
        {
        case let .direct(source, _, _):
            source
        case let .scoped(source, _, _, _):
            source
        }
    }

    package var text: String
    {
        switch self
        {
        case let .direct(_, text, _):
            text
        case let .scoped(_, text, _, _):
            text
        }
    }

    package var traits: Set<ProjectedInlineTrait>
    {
        switch self
        {
        case let .direct(_, _, traits):
            traits
        case let .scoped(_, _, traits, _):
            traits
        }
    }
}
