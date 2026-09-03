package enum ProjectedTableRecord: Equatable, Sendable
{
    case semantic(ProjectedTable)
    case sourced(
        table: ProjectedTable,
        evidence: ProjectedTableEvidence
    )

    package var table: ProjectedTable
    {
        switch self
        {
        case let .semantic(table):
            table
        case let .sourced(table, _):
            table
        }
    }
}
