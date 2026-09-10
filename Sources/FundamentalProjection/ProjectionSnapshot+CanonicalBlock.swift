import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ identified: IdentifiedSemanticBlock,
        ordinal: Int,
        listPosition: ProjectedListPosition
    ) -> ProjectedBlock
    {
        let blockID = identified.blockID.value
        let source = ProjectedBlockSource(
            blockID: blockID,
            ordinal: ordinal
        )
        switch identified.block
        {
        case let .listItem(item):
            return .prose(source: source, prose: ProjectedProse(
                role: item.kind == .bulleted
                    ? .bulleted(listPosition) : .numbered(listPosition),
                runs: projectBlockRuns(item.runs, blockID: blockID)
            ))
        case let .paragraph(paragraph):
            return .prose(
                source: source,
                prose: ProjectedProse(
                    role: .body,
                    runs: projectBlockRuns(
                        paragraph.runs,
                        blockID: blockID
                    )
                )
            )
        case let .heading(heading):
            return project(
                heading,
                source: source
            )
        case let .code(code):
            return project(
                code,
                source: source
            )
        case let .table(table):
            return .table(
                source: source,
                table: project(
                    table,
                    blockID: blockID
                )
            )
        }
    }

}
