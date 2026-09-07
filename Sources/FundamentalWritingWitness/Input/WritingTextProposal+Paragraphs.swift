import Foundation
import FundamentalDocument

extension WritingTextProposal
{
    static func paragraphEdit(
        _ replacement: String, in range: DocumentRange
    ) -> CanonicalDocumentEdit?
    {
        var paragraphs: [SemanticParagraph] = []
        for text in replacement.components(separatedBy: "\n")
        {
            if text.isEmpty
            {
                paragraphs.append(SemanticParagraph(runs: []))
            }
            else
            {
                guard let insertion = SemanticInsertion(
                    text: text, attributes: .direct(traits: [])
                )
                else
                {
                    return nil
                }
                paragraphs.append(SemanticParagraph(runs: [insertion.run]))
            }
        }
        let identities = paragraphs.dropFirst().map
        {
            _ in FundamentalBlockID(UUID())
        }
        guard let edit = SemanticParagraphReplacement(
            range: range, paragraphs: paragraphs,
            continuationBlockIDs: identities
        )
        else
        {
            return nil
        }
        return .paragraphs(edit)
    }
}
