struct ResolvedDocumentRange: Equatable, Sendable
{
    let range: DocumentRange
    let start: ResolvedDocumentPoint
    let end: ResolvedDocumentPoint

    init?(
        _ range: DocumentRange,
        in document: CanonicalDocument
    )
    {
        guard let start = ResolvedDocumentPoint(
            range.start,
            in: document
        ),
        let end = ResolvedDocumentPoint(
            range.end,
            in: document
        )
        else
        {
            return nil
        }

        let blocks = document.content.blocks
        let lowerIndex = min(start.blockIndex, end.blockIndex)
        let upperIndex = max(start.blockIndex, end.blockIndex)
        guard blocks[lowerIndex ... upperIndex].allSatisfy(
            { EditableSemanticBlock($0.block) != nil }
        )
        else
        {
            return nil
        }

        self.range = range
        self.start = start
        self.end = end
    }

    var lowerBound: ResolvedDocumentPoint
    {
        Self.isOrderedBeforeOrEqual(start, end) ? start : end
    }

    var upperBound: ResolvedDocumentPoint
    {
        guard start != end
        else
        {
            return start
        }
        return Self.isOrderedBeforeOrEqual(start, end) ? end : start
    }

    private static func isOrderedBeforeOrEqual(
        _ lhs: ResolvedDocumentPoint,
        _ rhs: ResolvedDocumentPoint
    ) -> Bool
    {
        guard lhs.blockIndex == rhs.blockIndex
        else
        {
            return lhs.blockIndex < rhs.blockIndex
        }
        return lhs.point.utf16Offset <= rhs.point.utf16Offset
    }
}
