struct AppliedSemanticParagraphReplacement: Equatable, Sendable
{
    let document: CanonicalDocument
    let caret: ResolvedDocumentPoint

    init?(
        _ replacement: SemanticParagraphReplacement,
        in source: CanonicalDocument
    )
    {
        let occupied = Set(source.content.blocks.map(\.blockID))
        guard replacement.continuationBlockIDs.allSatisfy(
            { !occupied.contains($0) }
        ),
              let range = ResolvedParagraphReplacement(replacement, in: source),
              let revision = DocumentRevision(after: source.revision),
              let content = Self.content(replacement, range: range, in: source),
              let offset = Self.caretOffset(replacement, range: range)
        else
        {
            return nil
        }
        let document = CanonicalDocument(
            documentID: source.documentID, revision: revision, content: content
        )
        let candidate = DocumentPoint(
            documentID: source.documentID,
            revision: revision,
            blockID: replacement.continuationBlockIDs.last ??
                range.lower.point.blockID,
            utf16Offset: offset
        )
        guard let caret = ResolvedPostEditCaret(
            candidate: candidate, affinity: replacement.affinity, in: document
        )
        else
        {
            return nil
        }
        self.document = document
        self.caret = caret.resolvedPoint
    }
}
