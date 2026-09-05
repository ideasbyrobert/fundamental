import Foundation
import FundamentalDocument

struct WritingTextProposal: Equatable, Sendable
{
    let command: DocumentSessionCommand

    init?(
        ranges: [NSRange],
        replacements: [String]?,
        in projection: WritingProjection
    )
    {
        guard ranges.count == 1,
              let replacements, replacements.count == 1,
              let range = projection.range(ranges[0]),
              WritingSurfacePolicy.admits(replacements[0])
        else
        {
            return nil
        }
        let replacement = replacements[0]
        let retained = projection.text.utf16.count - ranges[0].length
        let (count, overflow) = retained.addingReportingOverflow(
            replacement.utf16.count
        )
        guard !overflow, count <= WritingSurfacePolicy.maximumUTF16Units
        else
        {
            return nil
        }
        let edit: SemanticTextEdit
        if replacement.isEmpty
        {
            guard let deletion = SemanticTextDeletion(range: range)
            else
            {
                return nil
            }
            edit = .deletion(deletion)
        }
        else
        {
            guard let insertion = SemanticInsertion(
                text: replacement,
                attributes: .direct(traits: [])
            )
            else
            {
                return nil
            }
            if ranges[0].length == 0
            {
                edit = .insertion(SemanticTextInsertion(
                    point: range.start,
                    insertion: insertion
                ))
            }
            else
            {
                guard let replacement = SemanticTextReplacement(
                    range: range,
                    insertion: insertion
                )
                else
                {
                    return nil
                }
                edit = .replacement(replacement)
            }
        }
        command = .edit(projection.observation, .text(edit))
    }
}
