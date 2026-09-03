package enum ProjectedTableEvidenceTarget: Equatable, Sendable
{
    case table
    case row(Int)
    case cell(
        row: Int,
        cell: Int
    )
}
