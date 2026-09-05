package enum CanonicalDocumentEdit: Equatable, Sendable
{
    case text(SemanticTextEdit)
    case split(SemanticBlockSplit)
    case merge(SemanticBlockMerge)
}
