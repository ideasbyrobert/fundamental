struct AppliedCanonicalDocumentEdit: Equatable, Sendable
{
    let document: CanonicalDocument
    let caret: ResolvedDocumentPoint

    init?(
        _ edit: CanonicalDocumentEdit,
        in source: CanonicalDocument
    )
    {
        switch edit
        {
        case let .text(textEdit):
            guard let result = AppliedSemanticTextEdit(
                textEdit,
                in: source
            )
            else
            {
                return nil
            }
            document = result.document
            caret = result.caret
        case let .split(split):
            guard let result = AppliedSemanticBlockSplit(
                split,
                in: source
            )
            else
            {
                return nil
            }
            document = result.document
            caret = result.caret
        case let .merge(merge):
            guard let result = AppliedSemanticBlockMerge(
                merge,
                in: source
            )
            else
            {
                return nil
            }
            document = result.document
            caret = result.caret
        }
    }
}
