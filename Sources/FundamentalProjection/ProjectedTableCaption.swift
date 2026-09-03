package struct ProjectedTableCaption: Equatable, Sendable
{
    package let firstRun: ProjectedRun
    package let remainingRuns: [ProjectedRun]

    package var runs: [ProjectedRun]
    {
        [firstRun] + remainingRuns
    }
}
