package struct ProjectedTableEvidence: Equatable, Sendable
{
    package let firstFact: ProjectedTableEvidenceFact
    package let remainingFacts: [ProjectedTableEvidenceFact]

    package var facts: [ProjectedTableEvidenceFact]
    {
        [firstFact] + remainingFacts
    }
}
