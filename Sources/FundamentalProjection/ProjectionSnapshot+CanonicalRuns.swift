import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func projectRuns(
        _ runs: [SemanticRun],
        source: (Int, Int, Int) -> ProjectedTextSource
    ) -> [ProjectedRun]
    {
        var offset = 0
        return runs.enumerated().map
        {
            let lower = offset
            offset += $0.element.text.utf16.count
            let projectedSource = source($0.offset, lower, offset)
            let traits = Set($0.element.traits.map(project))
            switch $0.element
            {
            case let .direct(run):
                return .direct(
                    source: projectedSource,
                    text: run.text,
                    traits: traits
                )
            case let .scoped(run):
                return .scoped(
                    source: projectedSource,
                    text: run.text,
                    traits: traits,
                    scope: project(run.scopes)
                )
            }
        }
    }

}
