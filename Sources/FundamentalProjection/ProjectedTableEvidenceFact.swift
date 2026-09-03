package enum ProjectedTableEvidenceFact: Equatable, Sendable
{
    case sourceLocation(
        target: ProjectedTableEvidenceTarget,
        location: String
    )
    case confidence(
        target: ProjectedTableConfidenceTarget,
        value: Double
    )
    case repair(
        target: ProjectedTableEvidenceTarget,
        kind: ProjectedTableRepairKind
    )
}
