import Foundation
import FundamentalDocument

struct WritingDocumentSeed
{
    let state: DocumentSessionState

    init?()
    {
        let documentID = FundamentalDocumentID(UUID())
        let blockID = FundamentalBlockID(UUID())
        let block = IdentifiedSemanticBlock(
            blockID: blockID,
            block: .paragraph(SemanticParagraph(runs: []))
        )
        guard let content = CanonicalDocumentContent(
            firstBlock: block,
            remainingBlocks: []
        ),
              let offset = DocumentUTF16Offset(0)
        else
        {
            return nil
        }
        let document = CanonicalDocument(
            documentID: documentID,
            revision: .zero,
            content: content
        )
        let point = DocumentPoint(
            documentID: documentID,
            revision: .zero,
            blockID: blockID,
            utf16Offset: offset
        )
        guard let range = DocumentRange(start: point, end: point),
              let editable = EditableDocumentSnapshot(
                  snapshot: DocumentSnapshot(
                      generation: .zero,
                      document: document
                  ),
                  selection: DocumentSelection(range: range)
              )
        else
        {
            return nil
        }
        state = .editable(editable)
    }
}
