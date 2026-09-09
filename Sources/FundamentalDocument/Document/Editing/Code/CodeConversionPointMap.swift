struct CodeConversionPointMap: Equatable, Sendable
{
    let sourceBlockID: FundamentalBlockID
    let sourceRange: ClosedRange<Int>
    let blockID: FundamentalBlockID
    let offset: Int

    func successor(
        of point: DocumentPoint, in document: CanonicalDocument
    ) -> DocumentPoint?
    {
        guard point.blockID == sourceBlockID,
              sourceRange.contains(point.utf16Offset.value)
        else
        {
            return nil
        }
        let local = point.utf16Offset.value - sourceRange.lowerBound
        let (value, overflow) = offset.addingReportingOverflow(local)
        guard !overflow, let position = DocumentUTF16Offset(value)
        else
        {
            return nil
        }
        return DocumentPoint(
            documentID: document.documentID, revision: document.revision,
            blockID: blockID, utf16Offset: position
        )
    }
}
