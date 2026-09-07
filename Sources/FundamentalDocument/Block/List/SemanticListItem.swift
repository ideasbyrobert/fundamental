package struct SemanticListItem: Equatable, Sendable
{
    package let kind: SemanticListKind
    package let runs: [SemanticRun]

    package init(kind: SemanticListKind, runs: [SemanticRun])
    {
        self.kind = kind
        self.runs = runs
    }
}
