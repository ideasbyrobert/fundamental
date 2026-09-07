import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func projectCaptionRuns(
        _ runs: [SemanticRun],
        blockID: UUID
    ) -> [ProjectedRun]
    {
        projectRuns(runs)
        {
            .caption(
                blockID: blockID,
                run: $0,
                range: range($1, $2)
            )
        }
    }

}
