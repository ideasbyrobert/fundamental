package enum ProjectedTableConfidenceTarget: Equatable, Sendable
{
    case table
    case cell(
        row: Int,
        cell: Int
    )
}
