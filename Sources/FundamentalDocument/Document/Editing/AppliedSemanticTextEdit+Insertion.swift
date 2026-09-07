extension AppliedSemanticTextEdit
{
    init?(
        _ insertion: SemanticTextInsertion,
        in source: CanonicalDocument
    )
    {
        guard Self.isEditable(source),
              let point = ResolvedDocumentPoint(
                insertion.point,
                in: source
              ),
              let editableBlock = EditableSemanticBlock(
                source.content.blocks[point.blockIndex].block
              ),
              Self.admits(
                insertion.insertion.text,
                in: editableBlock
              ),
              let partition = SemanticRunPartition(
                runs: editableBlock.runs,
                lowerBound: insertion.point.utf16Offset,
                upperBound: insertion.point.utf16Offset
              ),
              let revision = DocumentRevision(after: source.revision)
        else
        {
            return nil
        }

        let runs = partition.prefix
            + [insertion.insertion.run]
            + partition.suffix
        guard let document = Self.replacing(
            blockAt: point.blockIndex,
            with: runs,
            revision: revision,
            in: source
        )
        else
        {
            return nil
        }

        let addition = insertion.point.utf16Offset.value
            .addingReportingOverflow(insertion.insertion.text.utf16.count)
        guard !addition.overflow,
              let offset = DocumentUTF16Offset(addition.partialValue)
        else
        {
            return nil
        }
        let candidate = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: insertion.point.blockID,
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
