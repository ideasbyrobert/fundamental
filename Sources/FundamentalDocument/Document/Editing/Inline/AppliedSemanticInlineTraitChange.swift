struct AppliedSemanticInlineTraitChange: Equatable, Sendable
{
    let content: CanonicalDocumentContent

    init?(_ change: SemanticInlineTraitChange, in source: CanonicalDocument)
    {
        guard let resolved = ResolvedDocumentRange(change.range, in: source)
        else
        {
            return nil
        }
        let lower = resolved.lowerBound
        let upper = resolved.upperBound
        var blocks = source.content.blocks
        for index in lower.blockIndex ... upper.blockIndex
        {
            guard let editable = EditableSemanticBlock(blocks[index].block),
                  let start = DocumentUTF16Offset(index == lower.blockIndex
                      ? lower.point.utf16Offset.value : 0),
                  let end = DocumentUTF16Offset(index == upper.blockIndex
                      ? upper.point.utf16Offset.value : editable.utf16Count)
            else
            {
                return nil
            }
            guard start < end
            else
            {
                continue
            }
            guard let runs = change.applying(
                to: editable.runs, lowerBound: start, upperBound: end
            )
            else
            {
                return nil
            }
            guard runs != editable.runs
            else
            {
                continue
            }
            blocks[index] = IdentifiedSemanticBlock(
                blockID: blocks[index].blockID,
                block: editable.replacingRuns(runs)
            )
        }
        guard let content = CanonicalDocumentContent(
            firstBlock: blocks[0], remainingBlocks: Array(blocks.dropFirst())
        )
        else
        {
            return nil
        }
        self.content = content
    }
}
