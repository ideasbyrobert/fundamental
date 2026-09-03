package enum ProjectedCode: Equatable, Sendable
{
    case plain([ProjectedRun])
    case languageTagged(
        language: String,
        runs: [ProjectedRun]
    )

    package var runs: [ProjectedRun]
    {
        switch self
        {
        case let .plain(runs):
            runs
        case let .languageTagged(_, runs):
            runs
        }
    }
}
