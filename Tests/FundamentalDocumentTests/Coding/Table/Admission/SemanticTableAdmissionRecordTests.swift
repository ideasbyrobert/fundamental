import Testing

@testable import FundamentalDocument

extension SemanticTableAdmissionTests
{
    @Test("empty facts publish a semantic record")
    func emptyFactsPublishSemanticRecord() throws
    {
        let table = try SourcedSemanticTableTests.table()
        let admission = try #require(SemanticTableAdmission(
            table: table,
            evidence: []
        ))

        #expect(admission.record == .semantic(table))
    }

    @Test("valid nonempty facts publish a sourced record")
    func validNonemptyFactsPublishSourcedRecord() throws
    {
        let table = try SourcedSemanticTableTests.table()
        let fact = try SemanticTableEvidenceTests.confidence(
            target: .table
        )
        let admission = try #require(SemanticTableAdmission(
            table: table,
            evidence: [fact]
        ))

        guard case let .sourced(sourced) = admission.record
        else
        {
            Issue.record("Expected a sourced record")
            return
        }
        #expect(sourced.table == table)
        #expect(sourced.evidence.facts == [fact])
    }

    @Test("invalid nonempty facts refuse admission atomically")
    func invalidNonemptyFactsRefuseAdmissionAtomically() throws
    {
        let emptyTable = try SourcedSemanticTableTests.table()
        let confidence = try SemanticTableEvidenceTests.confidence(
            target: .table
        )
        let row = try SemanticTableEvidenceTests.row(0)
        let location = try SemanticTableEvidenceTests.location(
            target: .row(row)
        )
        let repair = try SourcedSemanticTableTests.spanRepair(
            .nonpositiveRowSpanNormalizedToOne
        )
        let spanningTable = try SourcedSemanticTableTests.table(bodyRows: [[
            try SourcedSemanticTableTests.spanningCell(
                rowCount: 2,
                columnCount: 1
            )
        ], []])
        let cases = [
            (emptyTable, [confidence, confidence]),
            (emptyTable, [location]),
            (spanningTable, [repair])
        ]

        for (table, facts) in cases
        {
            #expect(SemanticTableAdmission(
                table: table,
                evidence: facts
            ) == nil)
        }
    }
}
