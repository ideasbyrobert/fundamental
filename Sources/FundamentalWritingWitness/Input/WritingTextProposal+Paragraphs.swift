import Foundation
import FundamentalDocument

extension WritingTextProposal
{
    static func paragraphEdit(
        _ replacement: String, in range: DocumentRange, sourceLines: Bool,
        attributes: SemanticRunAttributes
    ) -> CanonicalDocumentEdit?
    {
        var paragraphs: [SemanticParagraph] = []
        let parts = sourceLines ? [replacement] :
            replacement.components(separatedBy: "\n")
        for text in parts
        {
            if text.isEmpty
            {
                paragraphs.append(SemanticParagraph(runs: []))
            }
            else
            {
                guard let insertion = SemanticInsertion(
                    text: text, attributes: attributes
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
