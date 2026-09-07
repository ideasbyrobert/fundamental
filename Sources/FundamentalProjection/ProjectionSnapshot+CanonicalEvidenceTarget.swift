import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ target: SemanticTableEvidenceTarget
    ) -> ProjectedTableEvidenceTarget
    {
        switch target
        {
        case .table:
            .table
        case let .row(row):
            .row(row.value)
        case let .cell(row, cell):
            .cell(
                row: row.value,
                cell: cell.value
            )
        }
    }

}
