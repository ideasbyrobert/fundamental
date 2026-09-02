struct ResolvedDocumentDeletionRange: Equatable, Sendable
{
    let range: DocumentRange
    let blockIndex: Int

    init?(
        _ range: DocumentRange,
        in document: CanonicalDocument
    )
    {
        guard range.documentID == document.documentID,
              range.revision == document.revision,
              !range.isCollapsed,
              range.start.blockID == range.end.blockID
        else
        {
            return nil
        }

        let blocks = document.content.blocks
        guard let blockIndex = blocks.firstIndex(
            where:
            {
                $0.blockID == range.start.blockID
            }
        ),
        let editableBlock = EditableSemanticBlock(
            blocks[blockIndex].block
        ),
        editableBlock.admitsScalarBoundary(
            at: range.start.utf16Offset
        ),
        editableBlock.admitsScalarBoundary(
            at: range.end.utf16Offset
        )
        else
        {
            return nil
        }

        self.range = range
        self.blockIndex = blockIndex
    }

    var lowerUTF16Offset: DocumentUTF16Offset
    {
        min(range.start.utf16Offset, range.end.utf16Offset)
    }

    var upperUTF16Offset: DocumentUTF16Offset
    {
        max(range.start.utf16Offset, range.end.utf16Offset)
    }
}
