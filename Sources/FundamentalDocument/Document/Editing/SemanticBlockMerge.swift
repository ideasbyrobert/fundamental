struct SemanticBlockMerge: Equatable, Sendable
{
    let documentID: FundamentalDocumentID
    let revision: DocumentRevision
    let leadingBlockID: FundamentalBlockID
    let trailingBlockID: FundamentalBlockID

    init?(
        documentID: FundamentalDocumentID,
        revision: DocumentRevision,
        leadingBlockID: FundamentalBlockID,
        trailingBlockID: FundamentalBlockID
    )
    {
        guard leadingBlockID != trailingBlockID
        else
        {
            return nil
        }

        self.documentID = documentID
        self.revision = revision
        self.leadingBlockID = leadingBlockID
        self.trailingBlockID = trailingBlockID
    }
}
