struct InheritedTypingAttributes: Equatable, Sendable
{
    let attributes: SemanticRunAttributes

    init?(_ range: DocumentRange, in document: CanonicalDocument)
    {
        guard let resolved = ResolvedDocumentRange(range, in: document)
        else
        {
            return nil
        }
        let lower = resolved.lowerBound
        let upper = resolved.upperBound
        if !range.isCollapsed
        {
            for index in lower.blockIndex ... upper.blockIndex
            {
                guard let block = EditableSemanticBlock(
                    document.content.blocks[index].block
                )
                else
                {
                    return nil
                }
                let start = index == lower.blockIndex
                    ? lower.point.utf16Offset.value : 0
                let end = index == upper.blockIndex
                    ? upper.point.utf16Offset.value : block.utf16Count
                var position = 0
                for run in block.runs
                {
                    let before = position
                    let next = position.addingReportingOverflow(
                        run.text.utf16.count
                    )
                    guard !next.overflow
                    else
                    {
                        return nil
                    }
                    position = next.partialValue
                    if !run.text.isEmpty, before < end, position > start
                    {
                        attributes = run.attributes
                        return
                    }
                }
            }
        }
        guard let attributes = Self.attributes(at: lower, in: document)
        else
        {
            return nil
        }
        self.attributes = attributes
    }
}
