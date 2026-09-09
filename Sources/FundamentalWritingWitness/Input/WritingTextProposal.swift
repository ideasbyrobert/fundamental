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
              let context = WritingTextContext(ranges[0], in: projection)
        else
        {
            return nil
        }
        let range = context.range
        let replacement = context.replacement(replacements[0])
        let retained = projection.map.utf16Count - ranges[0].length
        let (count, overflow) = retained.addingReportingOverflow(
            replacement.utf16.count
        )
        let adjustment = context.seamAdjustment(
            replacing: ranges[0], with: replacement, in: projection
        )
        let (projectedCount, seamOverflow) = count.addingReportingOverflow(
            adjustment
        )
        guard !overflow, !seamOverflow,
              projectedCount <= WritingSurfacePolicy.maximumUTF16Units
        else
        {
            return nil
        }
        let inserted = context.isCode ? 0 : replacement.utf16.reduce(0)
        {
            $0 + ($1 == 0x0A ? 1 : 0)
        }
        let paragraphs = projection.map.spans.count - context.separators +
            inserted
        guard paragraphs <= WritingSurfacePolicy.maximumParagraphs
        else
        {
            return nil
        }
        let edit: CanonicalDocumentEdit?
        if !context.isCode && (context.separators > 0 ||
            replacement.contains("\n"))
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
