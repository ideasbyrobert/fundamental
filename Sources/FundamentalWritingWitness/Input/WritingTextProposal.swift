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
              replacements[0].utf16.count <=
                  WritingSurfacePolicy.maximumUTF16Units * 2,
              let range = projection.range(ranges[0])
        else
        {
            return nil
        }
        let replacement = replacements[0]
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let retained = projection.map.utf16Count - ranges[0].length
        let (count, overflow) = retained.addingReportingOverflow(
            replacement.utf16.count
        )
        guard !overflow, count <= WritingSurfacePolicy.maximumUTF16Units,
              let removed = projection.map.separatorCount(in: range)
        else
        {
            return nil
        }
        let inserted = replacement.utf16.reduce(0)
        {
            $0 + ($1 == 0x0A ? 1 : 0)
        }
        let paragraphs = projection.map.spans.count - removed + inserted
        guard paragraphs <= WritingSurfacePolicy.maximumParagraphs
        else
        {
            return nil
        }
        let edit: CanonicalDocumentEdit?
        if range.start.blockID != range.end.blockID ||
            replacement.contains("\n")
        {
            edit = Self.paragraphEdit(replacement, in: range)
        }
        else
        {
            edit = Self.textEdit(replacement, in: range)
        }
        guard let edit
        else
        {
            return nil
        }
        command = .edit(projection.observation, edit)
    }
}
