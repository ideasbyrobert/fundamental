enum SemanticTableConfidenceTarget: Equatable, Sendable
{
    case table
    case cell(
        row: SemanticTableRowIndex,
        cell: SemanticTableCellIndex
    )
}
