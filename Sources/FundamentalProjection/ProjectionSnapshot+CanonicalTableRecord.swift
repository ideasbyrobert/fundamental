import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ record: SemanticTableRecord,
        blockID: UUID
    ) -> ProjectedTableRecord
    {
        switch record
        {
        case let .semantic(table):
            return .semantic(
                project(
                    table,
                    blockID: blockID
                )
            )
        case let .sourced(sourced):
            return .sourced(
                table: project(
                    sourced.table,
                    blockID: blockID
                ),
                evidence: project(sourced.evidence)
            )
        }
    }

}
