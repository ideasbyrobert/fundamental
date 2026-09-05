package struct DocumentRange: Equatable, Sendable
{
    package let start: DocumentPoint
    package let end: DocumentPoint

    package init?(
        start: DocumentPoint,
        end: DocumentPoint
    )
    {
        guard start.documentID == end.documentID,
              start.revision == end.revision
        else
        {
            return nil
        }

        self.start = start
        self.end = end
    }

    private init(caretAt point: DocumentPoint)
    {
        start = point
        end = point
    }

    static func caret(at point: DocumentPoint) -> DocumentRange
    {
        DocumentRange(caretAt: point)
    }

    var documentID: FundamentalDocumentID
    {
        start.documentID
    }

    var revision: DocumentRevision
    {
        start.revision
    }

    var isCollapsed: Bool
    {
        start == end
    }
}
