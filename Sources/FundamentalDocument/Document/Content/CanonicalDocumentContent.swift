package struct CanonicalDocumentContent: Equatable, Sendable
{
    let firstBlock: IdentifiedSemanticBlock
    let remainingBlocks: [IdentifiedSemanticBlock]

    package init?(
        firstBlock: IdentifiedSemanticBlock,
        remainingBlocks: [IdentifiedSemanticBlock]
    )
    {
        var blockIDs = Set([firstBlock.blockID])
        for block in remainingBlocks
        {
            guard blockIDs.insert(block.blockID).inserted
            else
            {
                return nil
            }
        }

        self.firstBlock = firstBlock
        self.remainingBlocks = remainingBlocks
    }

    package var blocks: [IdentifiedSemanticBlock]
    {
        [firstBlock] + remainingBlocks
    }
}
