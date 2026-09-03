import FundamentalProjection

extension NativeTextKit2Layout
{
    func gridPlacements(
        _ content: ProjectedTableContent
    ) throws -> [NativeGridPlacement]
    {
        let header = content.headerRows.map
        {
            (scope: LayoutTableRowScope.header, row: $0)
        }
        let body = content.bodyRows.map
        {
            (scope: LayoutTableRowScope.body, row: $0)
        }
        let rows = header + body
        var occupiedUntil: [Int: Int] = [:]
        var placements: [NativeGridPlacement] = []
        for (rowTrack, scopedRow) in rows.enumerated()
        {
            for (sourceCell, cell) in scopedRow.row.cells.enumerated()
            {
                let facts = cellFacts(cell)
                let column = try firstAvailableColumn(
                    rowTrack: rowTrack,
                    columnSpan: facts.columnSpan,
                    occupiedUntil: occupiedUntil
                )
                let end = rowTrack.addingReportingOverflow(
                    facts.rowSpan
                )
                guard !end.overflow
                else
                {
                    throw LayoutFailure.unrepresentableGridExtent
                }
                for track in column ..< column + facts.columnSpan
                {
                    occupiedUntil[track] = max(
                        occupiedUntil[track] ?? 0,
                        end.partialValue
                    )
                }
                placements.append(NativeGridPlacement(
                    scope: scopedRow.scope,
                    sourceRow: scopedRow.row.index,
                    sourceCell: sourceCell,
                    rowTrack: rowTrack,
                    columnTrack: column,
                    rowSpan: facts.rowSpan,
                    columnSpan: facts.columnSpan,
                    alignment: facts.alignment,
                    runs: facts.runs
                ))
            }
        }
        return placements
    }

    func cellFacts(
        _ cell: ProjectedTableCell
    ) -> (
        rowSpan: Int,
        columnSpan: Int,
        alignment: ProjectedTableColumnAlignment,
        runs: [ProjectedRun]
    )
    {
        switch cell
        {
        case let .regular(runs, alignment):
            (1, 1, alignment, runs)
        case let .spanning(runs, alignment, extent):
            (
                extent.rowCount,
                extent.columnCount,
                alignment,
                runs
            )
        }
    }

    func firstAvailableColumn(
        rowTrack: Int,
        columnSpan: Int,
        occupiedUntil: [Int: Int]
    ) throws -> Int
    {
        var column = 0
        while true
        {
            let end = column.addingReportingOverflow(columnSpan)
            guard !end.overflow
            else
            {
                throw LayoutFailure.unrepresentableGridExtent
            }
            let occupied = (column ..< end.partialValue).contains
            {
                (occupiedUntil[$0] ?? 0) > rowTrack
            }
            if !occupied
            {
                return column
            }
            let next = column.addingReportingOverflow(1)
            guard !next.overflow
            else
            {
                throw LayoutFailure.unrepresentableGridExtent
            }
            column = next.partialValue
        }
    }

    func gridDimensions(
        _ content: ProjectedTableContent,
        placements: [NativeGridPlacement]
    ) throws -> (rows: Int, columns: Int)
    {
        let rowCount = content.headerRows.count.addingReportingOverflow(
            content.bodyRows.count
        )
        guard !rowCount.overflow
        else
        {
            throw LayoutFailure.unrepresentableGridExtent
        }
        let rows = rowCount.partialValue
        var columns = content.columnAlignments.count
        for placement in placements
        {
            let rowEnd = placement.rowTrack.addingReportingOverflow(
                placement.rowSpan
            )
            let columnEnd = placement.columnTrack.addingReportingOverflow(
                placement.columnSpan
            )
            guard !rowEnd.overflow,
                  !columnEnd.overflow,
                  rowEnd.partialValue <= rows
            else
            {
                throw LayoutFailure.unrepresentableGridExtent
            }
            columns = max(columns, columnEnd.partialValue)
        }
        return (rows, columns)
    }
}
