import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ target: SemanticTableConfidenceTarget
    ) -> ProjectedTableConfidenceTarget
    {
        switch target
        {
        case .table:
            .table
        case let .cell(row, cell):
            .cell(
                row: row.value,
                cell: cell.value
            )
        }
    }

}
