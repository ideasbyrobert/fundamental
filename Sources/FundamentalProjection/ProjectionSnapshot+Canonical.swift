import Foundation
import FundamentalDocument

package extension ProjectionSnapshot
{
    init(_ snapshot: DocumentSnapshot)
    {
        let document = snapshot.document
        let blocks = document.content.blocks.enumerated().map
        {
            Self.project(
                $0.element,
                ordinal: $0.offset
            )
        }
        lineage = ProjectionLineage(
            documentID: document.documentID.value,
            revision: document.revision.value,
            generation: snapshot.generation.value
        )
        firstBlock = blocks[0]
        remainingBlocks = Array(blocks.dropFirst())
    }

}
