struct AppliedSemanticBlockMerge: Equatable, Sendable
{
    let document: CanonicalDocument
    let caret: ResolvedDocumentPoint

    init?(
        _ merge: SemanticBlockMerge,
        in source: CanonicalDocument
    )
    {
        let blocks = source.content.blocks
        guard Self.isEditable(source),
              merge.documentID == source.documentID,
              merge.revision == source.revision,
              let leadingIndex = blocks.firstIndex(where:
              {
                  $0.blockID == merge.leadingBlockID
              }),
              let trailingIndex = blocks.firstIndex(where:
              {
                  $0.blockID == merge.trailingBlockID
              }),
              trailingIndex == leadingIndex + 1,
              let leading = EditableSemanticBlock(
                blocks[leadingIndex].block
              ),
              let trailing = EditableSemanticBlock(
                blocks[trailingIndex].block
              ),
              let block = Self.merging(
                leading,
                with: trailing
              ),
              let seam = DocumentUTF16Offset(leading.utf16Count),
              let revision = DocumentRevision(after: source.revision),
              let document = Self.replacing(
                leadingAt: leadingIndex,
                trailingAt: trailingIndex,
                with: block,
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
            blockID: merge.leadingBlockID,
            utf16Offset: seam
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
