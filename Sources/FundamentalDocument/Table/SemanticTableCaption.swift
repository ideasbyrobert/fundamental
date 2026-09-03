package struct SemanticTableCaption: Equatable, Sendable
{
    let firstRun: SemanticRun
    let remainingRuns: [SemanticRun]

    package var runs: [SemanticRun]
    {
        [firstRun] + remainingRuns
    }
}
