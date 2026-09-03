package struct SpanningSemanticTableCell: Equatable, Sendable
{
    package let runs: [SemanticRun]
    package let alignment: SemanticTableColumnAlignment
    package let extent: SemanticTableCellExtent

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
