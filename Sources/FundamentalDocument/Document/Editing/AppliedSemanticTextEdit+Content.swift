extension AppliedSemanticTextEdit
{
    static func isEditable(_ document: CanonicalDocument) -> Bool
    {
        document.content.blocks.allSatisfy
        {
            EditableSemanticBlock($0.block) != nil
        }
    }

    static func admits(
        _ text: String,
        in block: EditableSemanticBlock
    ) -> Bool
    {
        switch block
        {
        case .code:
            true
        case .paragraph, .heading, .listItem:
            !text.unicodeScalars.contains
            {
                $0.value == 0x0A || $0.value == 0x0D
            }
        }
    }

    static func replacing(
        blockAt index: Int,
        with runs: [SemanticRun],
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
            block: editableBlock.replacingRuns(runs)
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
