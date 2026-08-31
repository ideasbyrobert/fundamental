struct SemanticTableCaption: Equatable, Sendable
{
    let firstRun: SemanticRun
    let remainingRuns: [SemanticRun]

    var runs: [SemanticRun]
    {
        [firstRun] + remainingRuns
    }
}
