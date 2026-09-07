import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func projectBlockRuns(
        _ runs: [SemanticRun],
        blockID: UUID
    ) -> [ProjectedRun]
    {
        projectRuns(runs)
        {
            .block(
                blockID: blockID,
                run: $0,
                range: range($1, $2)
            )
        }
    }

}
