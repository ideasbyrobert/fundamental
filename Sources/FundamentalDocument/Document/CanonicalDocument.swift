package struct CanonicalDocument: Equatable, Sendable
{
    package let documentID: FundamentalDocumentID
    package let revision: DocumentRevision
    package let content: CanonicalDocumentContent

    package init(
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
