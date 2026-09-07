package struct SemanticBlockSelection: Equatable, Sendable
{
    package let blocks: [IdentifiedSemanticBlock]
    let indices: ClosedRange<Int>

    package init?(range: DocumentRange, in document: CanonicalDocument)
    {
        guard let resolved = ResolvedDocumentRange(range, in: document)
        else
        {
            return nil
        }
        let lower = resolved.lowerBound.blockIndex
        let upper = resolved.upperBound.blockIndex
        let endsAtStart = lower < upper &&
            resolved.upperBound.point.utf16Offset.value == 0
        indices = lower ... (endsAtStart ? upper - 1 : upper)
        blocks = Array(document.content.blocks[indices])
    }
}
