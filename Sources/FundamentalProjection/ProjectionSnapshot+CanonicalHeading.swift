import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ heading: SemanticHeading,
        source: ProjectedBlockSource
    ) -> ProjectedBlock
    {
        let role: ProjectedProseRole
        switch heading
        {
        case .title:
            role = .title
        case let .section(section):
            role = .section(project(section.level))
        }
        return .prose(
            source: source,
            prose: ProjectedProse(
                role: role,
                runs: heading.runs,
                blockID: source.blockID
            )
        )
    }

}
