struct SpanningSemanticTableCell: Equatable, Sendable
{
    let runs: [SemanticRun]
    let alignment: SemanticTableColumnAlignment
    let extent: SemanticTableCellExtent

    init(
        runs: [SemanticRun],
        alignment: SemanticTableColumnAlignment = .unspecified,
        extent: SemanticTableCellExtent
    )
    {
        self.runs = runs
        self.alignment = alignment
        self.extent = extent
    }
}
