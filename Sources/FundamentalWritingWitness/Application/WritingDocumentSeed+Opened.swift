import FundamentalDocument

extension WritingDocumentSeed
{
    init?(document: CanonicalDocument)
    {
        guard let first = document.content.blocks.first,
              let offset = DocumentUTF16Offset(0)
        else
        {
            return nil
        }
        let point = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: first.blockID,
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
