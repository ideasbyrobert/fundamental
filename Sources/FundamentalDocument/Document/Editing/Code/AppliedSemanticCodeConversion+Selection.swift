extension AppliedSemanticCodeConversion
{
    func selection(
        _ selection: DocumentSelection, from source: CanonicalDocument,
        to document: CanonicalDocument
    ) -> DocumentSelection?
    {
        guard ResolvedDocumentRange(selection.range, in: source) != nil,
              let start = successor(of: selection.range.start, in: document),
              let end = successor(of: selection.range.end, in: document),
              let range = DocumentRange(start: start, end: end),
              ResolvedDocumentRange(range, in: document) != nil
        else
        {
            return nil
        }
        return DocumentSelection(range: range)
    }

    private func successor(
        of point: DocumentPoint, in document: CanonicalDocument
    ) -> DocumentPoint?
    {
        let candidates = mappings.filter { $0.sourceBlockID == point.blockID }
        if !candidates.isEmpty
        {
            return candidates.lazy.compactMap
            {
                $0.successor(of: point, in: document)
            }.first
        }
        return DocumentPoint(
            documentID: document.documentID, revision: document.revision,
            blockID: point.blockID, utf16Offset: point.utf16Offset
        )
    }
}
