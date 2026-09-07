struct AppliedSemanticBlockSplit: Equatable, Sendable
{
    let document: CanonicalDocument
    let caret: ResolvedDocumentPoint

    init?(
        _ split: SemanticBlockSplit,
        in source: CanonicalDocument
    )
    {
        guard Self.isEditable(source),
              let point = ResolvedDocumentPoint(
                split.point,
                in: source
              ),
              !source.content.blocks.contains(where:
              {
                  $0.blockID == split.continuationBlockID
              }),
              let editableBlock = EditableSemanticBlock(
                source.content.blocks[point.blockIndex].block
              ),
              let partition = SemanticRunPartition(
                runs: editableBlock.runs,
                lowerBound: split.point.utf16Offset,
                upperBound: split.point.utf16Offset
              ),
              let revision = DocumentRevision(after: source.revision),
              let document = Self.splitting(
                blockAt: point.blockIndex,
                into: partition,
                continuationBlockID: split.continuationBlockID,
                revision: revision,
                in: source
              ),
              let zero = DocumentUTF16Offset(0)
        else
        {
            return nil
        }

        let candidate = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: split.continuationBlockID,
            utf16Offset: zero
        )
        guard let caret = ResolvedDocumentPoint(
            candidate,
            in: document
        )
        else
        {
            return nil
        }

        self.document = document
        self.caret = caret
    }
}
