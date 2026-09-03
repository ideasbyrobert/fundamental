package enum SemanticTableEvidenceTarget: Equatable, Sendable
{
    case table
    case row(SemanticTableRowIndex)
    case cell(
        row: SemanticTableRowIndex,
        cell: SemanticTableCellIndex
    )
}
