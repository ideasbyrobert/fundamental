struct AppliedSemanticTextEdit: Equatable, Sendable
{
    let document: CanonicalDocument
    let caret: ResolvedDocumentPoint

    init?(
        _ edit: SemanticTextEdit,
        in source: CanonicalDocument
    )
    {
        switch edit
        {
        case let .insertion(insertion):
            self.init(insertion, in: source)
        case let .deletion(deletion):
            self.init(deletion, in: source)
        case let .replacement(replacement):
            self.init(replacement, in: source)
        }
    }
}
