package struct SemanticParagraph: Equatable, Sendable
{
    package let runs: [SemanticRun]

    package init(runs: [SemanticRun])
    {
        self.runs = runs
    }
}
