package struct RegularSemanticTableCell: Equatable, Sendable
{
    package let runs: [SemanticRun]
    package let alignment: SemanticTableColumnAlignment

    init(
        runs: [SemanticRun],
        alignment: SemanticTableColumnAlignment = .unspecified
    )
    {
        self.runs = runs
        self.alignment = alignment
    }
}
