enum SemanticTextEdit: Equatable, Sendable
{
    case insertion(SemanticTextInsertion)
    case deletion(SemanticTextDeletion)
    case replacement(SemanticTextReplacement)
}
