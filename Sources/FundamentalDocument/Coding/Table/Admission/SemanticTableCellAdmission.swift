struct SemanticTableCellAdmission: Equatable, Sendable
{
    let cell: SemanticTableCell
    let legacyHeaderClaim: Bool
    let evidence: [SemanticTableEvidenceFact]
}
