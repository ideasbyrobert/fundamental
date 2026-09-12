import Foundation
import FundamentalDocument

struct WritingRecoveryPoint: Codable
{
    let block: UUID
    let offset: Int

    init(_ point: DocumentPoint)
    {
        block = point.blockID.value
        offset = point.utf16Offset.value
    }

    func point(in document: CanonicalDocument) -> DocumentPoint?
    {
        guard let offset = DocumentUTF16Offset(offset)
        else
        {
            return nil
        }
        return DocumentPoint(
            documentID: document.documentID, revision: document.revision,
            blockID: FundamentalBlockID(block), utf16Offset: offset
        )
    }
}
