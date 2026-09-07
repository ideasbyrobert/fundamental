extension AppliedSemanticTextEdit
{
    init?(
        _ replacement: SemanticTextReplacement,
        in source: CanonicalDocument
    )
    {
        guard Self.isEditable(source),
              let range = ResolvedDocumentDeletionRange(
                replacement.range,
                in: source
              ),
              let editableBlock = EditableSemanticBlock(
                source.content.blocks[range.blockIndex].block
              ),
              Self.admits(
                replacement.insertion.text,
                in: editableBlock
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

        let runs = partition.prefix
            + [replacement.insertion.run]
            + partition.suffix
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

        let addition = range.lowerUTF16Offset.value
            .addingReportingOverflow(replacement.insertion.text.utf16.count)
        guard !addition.overflow,
              let offset = DocumentUTF16Offset(addition.partialValue)
        else
        {
            return nil
        }
        let candidate = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: replacement.range.start.blockID,
            utf16Offset: offset
        )
        guard let caret = ResolvedPostEditCaret(
            candidate: candidate,
            affinity: .following,
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
