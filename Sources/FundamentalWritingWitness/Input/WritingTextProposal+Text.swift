import FundamentalDocument

extension WritingTextProposal
{
    static func textEdit(
        _ replacement: String, in range: DocumentRange
    ) -> CanonicalDocumentEdit?
    {
        if replacement.isEmpty
        {
            guard let deletion = SemanticTextDeletion(range: range)
            else
            {
                return nil
            }
            return .text(.deletion(deletion))
        }
        guard let insertion = SemanticInsertion(
            text: replacement, attributes: .direct(traits: [])
        )
        else
        {
            return nil
        }
        if range.start == range.end
        {
            return .text(.insertion(SemanticTextInsertion(
                point: range.start, insertion: insertion
            )))
        }
        guard let replacement = SemanticTextReplacement(
            range: range, insertion: insertion
        )
        else
        {
            return nil
        }
        return .text(.replacement(replacement))
    }
}
