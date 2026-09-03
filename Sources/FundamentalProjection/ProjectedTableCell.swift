package enum ProjectedTableCell: Equatable, Sendable
{
    case regular(
        runs: [ProjectedRun],
        alignment: ProjectedTableColumnAlignment
    )
    case spanning(
        runs: [ProjectedRun],
        alignment: ProjectedTableColumnAlignment,
        extent: ProjectedTableCellExtent
    )

    package var runs: [ProjectedRun]
    {
        switch self
        {
        case let .regular(runs, _):
            runs
        case let .spanning(runs, _, _):
            runs
        }
    }
}
