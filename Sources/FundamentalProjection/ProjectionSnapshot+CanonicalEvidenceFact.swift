import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ fact: SemanticTableEvidenceFact
    ) -> ProjectedTableEvidenceFact
    {
        switch fact
        {
        case let .sourceLocation(target, location):
            return .sourceLocation(
                target: project(target),
                location: location.value
            )
        case let .confidence(target, confidence):
            return .confidence(
                target: project(target),
                value: confidence.value
            )
        case let .repair(repair):
            return .repair(
                target: project(repair.target),
                kind: project(repair.kind)
            )
        }
    }

}
