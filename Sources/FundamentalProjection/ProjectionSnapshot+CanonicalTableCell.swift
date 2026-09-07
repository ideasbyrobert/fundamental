import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ cell: SemanticTableCell,
        row: Int,
        cell cellIndex: Int,
        blockID: UUID
    ) -> ProjectedTableCell
    {
        switch cell
        {
        case let .regular(cell):
            return .regular(
                runs: projectCellRuns(
                    cell.runs,
                    blockID: blockID,
                    row: row,
                    cell: cellIndex
                ),
                alignment: project(cell.alignment)
            )
        case let .spanning(cell):
            return .spanning(
                runs: projectCellRuns(
                    cell.runs,
                    blockID: blockID,
                    row: row,
                    cell: cellIndex
                ),
                alignment: project(cell.alignment),
                extent: ProjectedTableCellExtent(cell.extent)
            )
        }
    }

}
