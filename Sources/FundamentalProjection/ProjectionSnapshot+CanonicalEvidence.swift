import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ evidence: SemanticTableEvidence
    ) -> ProjectedTableEvidence
    {
        let facts = evidence.facts.map(project)
        return ProjectedTableEvidence(
            firstFact: facts[0],
            remainingFacts: Array(facts.dropFirst())
        )
    }

}
