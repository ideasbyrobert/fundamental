import Foundation
import FundamentalDocument

extension WritingTextProposal
{
    static func admitsCount(
        replacing range: NSRange, with replacement: String,
        context: WritingTextContext, in projection: WritingProjection
    ) -> Bool
    {
        let retained = projection.map.utf16Count - range.length
        let (count, overflow) = retained.addingReportingOverflow(
            replacement.utf16.count
        )
        let adjustment = context.seamAdjustment(
            replacing: range, with: replacement, in: projection
        )
        let (projectedCount, seamOverflow) = count.addingReportingOverflow(
            adjustment
        )
        return !overflow && !seamOverflow &&
            projectedCount <= WritingSurfacePolicy.maximumUTF16Units
    }

    static func admits(
        _ command: DocumentSessionCommand, in projection: WritingProjection
    ) -> Bool
    {
        guard case let .applied(state) = DocumentSessionTransition(
            command, in: .editable(projection.snapshot)
        )
        else
        {
            return false
        }
        return WritingProjection(state) != nil
    }
}
