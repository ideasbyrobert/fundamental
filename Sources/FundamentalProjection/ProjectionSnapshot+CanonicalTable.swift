import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ table: SemanticTable,
        blockID: UUID
    ) -> ProjectedTable
    {
        switch table
        {
        case let .regular(table):
            return .regular(
                project(
                    table.content,
                    blockID: blockID
                )
            )
        case let .captioned(table):
            return .captioned(
                content: project(
                    table.content,
                    blockID: blockID
                ),
                caption: project(
                    table.caption,
                    blockID: blockID
                )
            )
        }
    }

}
