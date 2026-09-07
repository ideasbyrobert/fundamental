import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ cells: [SemanticTableCell],
        row: Int,
        blockID: UUID
    ) -> ProjectedTableRow
    {
        ProjectedTableRow(
            index: row,
            cells: cells.enumerated().map
            {
                project(
                    $0.element,
                    row: row,
                    cell: $0.offset,
                    blockID: blockID
                )
            }
        )
    }

}
