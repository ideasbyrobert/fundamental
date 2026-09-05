package struct DocumentPoint: Equatable, Sendable
{
    let documentID: FundamentalDocumentID
    let revision: DocumentRevision
    let blockID: FundamentalBlockID
    package let utf16Offset: DocumentUTF16Offset

    package init(
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
