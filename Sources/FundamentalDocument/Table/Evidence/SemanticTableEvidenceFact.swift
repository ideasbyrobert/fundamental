package enum SemanticTableEvidenceFact: Equatable, Sendable
{
    case sourceLocation(
        target: SemanticTableEvidenceTarget,
        location: SemanticTableSourceLocation
    )
    case confidence(
        target: SemanticTableConfidenceTarget,
        confidence: SemanticTableConfidence
    )
    case repair(SemanticTableRepair)
}
