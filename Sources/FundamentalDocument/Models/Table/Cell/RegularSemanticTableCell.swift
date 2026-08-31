struct RegularSemanticTableCell: Equatable, Sendable
{
    let runs: [SemanticRun]
    let alignment: SemanticTableColumnAlignment

    init(
        runs: [SemanticRun],
        alignment: SemanticTableColumnAlignment = .unspecified
    )
    {
        self.runs = runs
        self.alignment = alignment
    }
}
