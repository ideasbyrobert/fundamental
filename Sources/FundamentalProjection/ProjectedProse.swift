import Foundation
import FundamentalDocument

package struct ProjectedProse: Equatable, Sendable
{
    package let role: ProjectedProseRole
    package let runs: [ProjectedRun]
    package let paragraph: SemanticParagraph

    package init(
        role: ProjectedProseRole, runs: [SemanticRun], blockID: UUID
    )
    {
        self.role = role
        paragraph = SemanticParagraph(runs: runs)
        self.runs = ProjectionSnapshot.projectBlockRuns(runs, blockID: blockID)
    }
}
