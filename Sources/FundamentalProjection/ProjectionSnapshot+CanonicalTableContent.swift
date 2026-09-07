import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ content: SemanticTableContent,
        blockID: UUID
    ) -> ProjectedTableContent
    {
        let headerRows = content.headerRows.enumerated().map
        {
            project(
                $0.element.cells,
                row: $0.offset,
                blockID: blockID
            )
        }
        let headerCount = headerRows.count
        let bodyRows = content.bodyRows.enumerated().map
        {
            project(
                $0.element.cells,
                row: headerCount + $0.offset,
                blockID: blockID
            )
        }
        return ProjectedTableContent(
            headerRows: headerRows,
            bodyRows: bodyRows,
            columnAlignments: content.columnAlignments.map(project)
        )
    }

}
