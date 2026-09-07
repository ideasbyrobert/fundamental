import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ caption: SemanticTableCaption,
        blockID: UUID
    ) -> ProjectedTableCaption
    {
        let runs = projectCaptionRuns(
            caption.runs,
            blockID: blockID
        )
        return ProjectedTableCaption(
            firstRun: runs[0],
            remainingRuns: Array(runs.dropFirst())
        )
    }

}
