enum SemanticTextBatchResult
{
    case unchanged
    case changed(CanonicalDocumentContent, blockIndex: Int, caretOffset: Int)
}
