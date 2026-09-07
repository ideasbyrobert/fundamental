import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func projectCellRuns(
        _ runs: [SemanticRun],
        blockID: UUID,
        row: Int,
        cell: Int
    ) -> [ProjectedRun]
    {
        projectRuns(runs)
        {
            .cell(
                blockID: blockID,
                row: row,
                cell: cell,
                run: $0,
                range: range($1, $2)
            )
        }
    }

}
