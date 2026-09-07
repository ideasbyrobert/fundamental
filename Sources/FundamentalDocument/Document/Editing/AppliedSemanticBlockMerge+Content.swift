extension AppliedSemanticBlockMerge
{
    static func replacing(
        leadingAt leadingIndex: Int,
        trailingAt trailingIndex: Int,
        with block: SemanticBlock,
        revision: DocumentRevision,
        in source: CanonicalDocument
    ) -> CanonicalDocument?
    {
        var blocks = source.content.blocks
        let leadingID = blocks[leadingIndex].blockID
        blocks[leadingIndex] = IdentifiedSemanticBlock(
            blockID: leadingID,
            block: block
        )
        blocks.remove(at: trailingIndex)

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
