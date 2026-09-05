import Foundation
import FundamentalDocument

struct WritingSelectionProposal: Equatable, Sendable
{
    let command: DocumentSessionCommand

    init?(ranges: [NSRange], in projection: WritingProjection)
    {
        guard ranges.count == 1, let range = projection.range(ranges[0])
        else
        {
            return nil
        }
        command = .select(
            projection.observation,
            DocumentSelection(range: range)
        )
    }
}
