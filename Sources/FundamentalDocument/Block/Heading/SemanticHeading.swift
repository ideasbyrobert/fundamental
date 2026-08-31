enum SemanticHeading: Equatable, Sendable
{
    case title(TitleSemanticHeading)
    case section(SectionSemanticHeading)

    var runs: [SemanticRun]
    {
        switch self
        {
        case let .title(heading):
            heading.runs
        case let .section(heading):
            heading.runs
        }
    }

    var level: SemanticHeadingLevel
    {
        switch self
        {
        case .title:
            .one
        case let .section(heading):
            heading.level
        }
    }
}
