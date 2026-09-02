struct ResolvedPostEditCaret: Equatable, Sendable
{
    let resolvedPoint: ResolvedDocumentPoint

    init?(
        candidate: DocumentPoint,
        affinity: PostEditCaretAffinity,
        in document: CanonicalDocument
    )
    {
        guard candidate.documentID == document.documentID,
              candidate.revision == document.revision
        else
        {
            return nil
        }

        let blocks = document.content.blocks
        guard let block = blocks.first(
            where:
            {
                $0.blockID == candidate.blockID
            }
        ),
        let editableBlock = EditableSemanticBlock(block.block),
        let offset = editableBlock.characterBoundary(
            resolving: candidate.utf16Offset,
            affinity: affinity
        )
        else
        {
            return nil
        }

        let point = DocumentPoint(
            documentID: candidate.documentID,
            revision: candidate.revision,
            blockID: candidate.blockID,
            utf16Offset: offset
        )
        guard let resolvedPoint = ResolvedDocumentPoint(
            point,
            in: document
        )
        else
        {
            return nil
        }

        self.resolvedPoint = resolvedPoint
    }
}
