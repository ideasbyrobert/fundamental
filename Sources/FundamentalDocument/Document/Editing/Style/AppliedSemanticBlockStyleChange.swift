struct AppliedSemanticBlockStyleChange: Equatable, Sendable
{
    let content: CanonicalDocumentContent

    init?(_ change: SemanticBlockStyleChange, in source: CanonicalDocument)
    {
        guard let selected = SemanticBlockSelection(
            range: change.range, in: source
        )
        else
        {
            return nil
        }
        var blocks = source.content.blocks
        for index in selected.indices
        {
            guard let block = change.operation.applying(
                to: blocks[index].block
            )
            else
            {
                return nil
            }
            blocks[index] = IdentifiedSemanticBlock(
                blockID: blocks[index].blockID,
                block: block
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
