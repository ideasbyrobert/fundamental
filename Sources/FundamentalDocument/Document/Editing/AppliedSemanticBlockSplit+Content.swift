extension AppliedSemanticBlockSplit
{
    static func isEditable(_ document: CanonicalDocument) -> Bool
    {
        document.content.blocks.allSatisfy
        {
            EditableSemanticBlock($0.block) != nil
        }
    }

    static func splitting(
        blockAt index: Int,
        into partition: SemanticRunPartition,
        continuationBlockID: FundamentalBlockID,
        revision: DocumentRevision,
        in source: CanonicalDocument
    ) -> CanonicalDocument?
    {
        var blocks = source.content.blocks
        let identified = blocks[index]
        guard let editableBlock = EditableSemanticBlock(identified.block)
        else
        {
            return nil
        }

        blocks[index] = IdentifiedSemanticBlock(
            blockID: identified.blockID,
            block: editableBlock.replacingRuns(partition.prefix)
        )
        blocks.insert(
            IdentifiedSemanticBlock(
                blockID: continuationBlockID,
                block: editableBlock.replacingRuns(partition.suffix)
            ),
            at: index + 1
        )

        guard let first = blocks.first,
              let content = CanonicalDocumentContent(
                firstBlock: first,
                remainingBlocks: Array(blocks.dropFirst())
              )
        else
        {
            return nil
        }
        return CanonicalDocument(
            documentID: source.documentID,
            revision: revision,
            content: content
        )
    }

}
