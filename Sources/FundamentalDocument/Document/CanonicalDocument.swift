struct CanonicalDocument: Equatable, Sendable
{
    let documentID: FundamentalDocumentID
    let revision: DocumentRevision
    let content: CanonicalDocumentContent

    init(
        documentID: FundamentalDocumentID,
        revision: DocumentRevision,
        content: CanonicalDocumentContent
    )
    {
        self.documentID = documentID
        self.revision = revision
        self.content = content
    }
}
