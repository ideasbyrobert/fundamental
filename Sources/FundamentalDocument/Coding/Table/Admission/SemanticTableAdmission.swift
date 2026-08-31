struct SemanticTableAdmission: Equatable, Sendable
{
    let record: SemanticTableRecord

    init?(
        table: SemanticTable,
        evidence: [SemanticTableEvidenceFact]
    )
    {
        guard let firstFact = evidence.first
        else
        {
            record = .semantic(table)
            return
        }
        guard let semanticEvidence = SemanticTableEvidence(
            firstFact: firstFact,
            remainingFacts: Array(evidence.dropFirst())
        ),
        let sourcedTable = SourcedSemanticTable(
            table: table,
            evidence: semanticEvidence
        )
        else
        {
            return nil
        }

        record = .sourced(sourcedTable)
    }
}
