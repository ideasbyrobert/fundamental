struct DocumentPoint: Equatable, Sendable
{
    let documentID: FundamentalDocumentID
    let revision: DocumentRevision
    let blockID: FundamentalBlockID
    let utf16Offset: DocumentUTF16Offset

    init(
        documentID: FundamentalDocumentID,
        revision: DocumentRevision,
        blockID: FundamentalBlockID,
        utf16Offset: DocumentUTF16Offset
    )
    {
        self.documentID = documentID
        self.revision = revision
        self.blockID = blockID
        self.utf16Offset = utf16Offset
    }
}
