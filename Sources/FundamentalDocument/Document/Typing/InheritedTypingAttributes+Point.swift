extension InheritedTypingAttributes
{
    static func attributes(
        at point: ResolvedDocumentPoint, in document: CanonicalDocument
    ) -> SemanticRunAttributes?
    {
        guard let block = EditableSemanticBlock(
            document.content.blocks[point.blockIndex].block
        )
        else
        {
            return nil
        }
        var position = 0
        for run in block.runs where !run.text.isEmpty
        {
            let next = position.addingReportingOverflow(run.text.utf16.count)
            guard !next.overflow
            else
            {
                return nil
            }
            position = next.partialValue
            if point.point.utf16Offset.value <= position
            {
                return run.attributes
            }
        }
        return point.point.utf16Offset.value == 0 ? .direct(traits: []) : nil
    }
}
