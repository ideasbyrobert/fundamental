import Foundation
import FundamentalDocument

package extension ProjectionSnapshot
{
    init(_ snapshot: DocumentSnapshot)
    {
        let document = snapshot.document
        let blocks = Self.projectBlocks(document.content.blocks)
        lineage = ProjectionLineage(
            documentID: document.documentID.value,
            revision: document.revision.value,
            generation: snapshot.generation.value
        )
        firstBlock = blocks[0]
        remainingBlocks = Array(blocks.dropFirst())
    }

}
