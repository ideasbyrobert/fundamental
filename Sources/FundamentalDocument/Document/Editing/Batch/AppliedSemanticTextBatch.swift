struct AppliedSemanticTextBatch
{
    let result: SemanticTextBatchResult

    init?(_ batch: SemanticTextBatchReplacement, in source: CanonicalDocument)
    {
        guard AppliedSemanticTextEdit.isEditable(source)
        else
        {
            return nil
        }
        var groups: [Int: [SemanticTextSubstitution]] = [:]
        for value in batch.substitutions
        {
            guard value.range.documentID == source.documentID,
                  value.range.revision == source.revision,
                  let index = source.content.blocks.firstIndex(where:
                    { $0.blockID == value.range.start.blockID })
            else
            {
                return nil
            }
            groups[index, default: []].append(value)
        }
        var blocks = source.content.blocks
        var firstChange: (Int, Int)?
        for index in blocks.indices
        {
            guard let values = groups[index]
            else
            {
                continue
            }
            let identified = blocks[index]
            guard let block = EditableSemanticBlock(identified.block),
                  let change = SemanticTextBatchBlock(values, in: block)
            else
            {
                return nil
            }
            guard let offset = change.firstChangedEnd
            else
            {
                continue
            }
            if firstChange == nil
            {
                firstChange = (index, offset)
            }
            blocks[index] = IdentifiedSemanticBlock(
                blockID: identified.blockID,
                block: block.replacingRuns(change.runs)
            )
        }
        guard let (index, offset) = firstChange
        else
        {
            result = .unchanged
            return
        }
        guard let first = blocks.first,
              let content = CanonicalDocumentContent(
                  firstBlock: first, remainingBlocks: Array(blocks.dropFirst())
              )
        else
        {
            return nil
        }
        result = .changed(content, blockIndex: index, caretOffset: offset)
    }
}
