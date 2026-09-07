extension AppliedSemanticTextEdit
{
    init?(
        _ deletion: SemanticTextDeletion,
        in source: CanonicalDocument
    )
    {
        guard Self.isEditable(source),
              let range = ResolvedDocumentDeletionRange(
                deletion.range,
                in: source
              ),
              let editableBlock = EditableSemanticBlock(
                source.content.blocks[range.blockIndex].block
              ),
              let partition = SemanticRunPartition(
                runs: editableBlock.runs,
                lowerBound: range.lowerUTF16Offset,
                upperBound: range.upperUTF16Offset
              ),
              let revision = DocumentRevision(after: source.revision)
        else
        {
            return nil
        }

        let runs = partition.prefix + partition.suffix
        guard let document = Self.replacing(
            blockAt: range.blockIndex,
            with: runs,
            revision: revision,
            in: source
        )
        else
        {
            return nil
        }

        let candidate = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: deletion.range.start.blockID,
            utf16Offset: range.lowerUTF16Offset
        )
        guard let caret = ResolvedPostEditCaret(
            candidate: candidate,
            affinity: .preceding,
            in: document
        )
        else
        {
            return nil
        }

        self.document = document
        self.caret = caret.resolvedPoint
    }

}
