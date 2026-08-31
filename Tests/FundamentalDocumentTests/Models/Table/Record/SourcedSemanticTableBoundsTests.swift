import Testing

@testable import FundamentalDocument

extension SourcedSemanticTableTests
{
    @Test("table and last normalized targets are admitted")
    func tableAndLastNormalizedTargetsAreAdmitted() throws
    {
        let table = Self.table(
            headerRows: [[Self.regularCell("Header")]],
            bodyRows: [[
                Self.regularCell("First"),
                Self.regularCell("Last")
            ]]
        )
        let row = try SemanticTableEvidenceTests.row(1)
        let cell = try SemanticTableEvidenceTests.cell(1)
        let facts = try [
            SemanticTableEvidenceTests.location(target: .table),
            SemanticTableEvidenceTests.location(target: .row(row)),
            SemanticTableEvidenceTests.confidence(
                target: .cell(row: row, cell: cell)
            )
        ]

        #expect(try Self.sourced(table: table, facts: facts)
            .evidence.facts.count == 3)
    }

    @Test("out-of-bounds row targets are refused")
    func outOfBoundsRowTargetsAreRefused() throws
    {
        let table = Self.table(bodyRows: [[Self.regularCell()]])
        for value in [1, Int.max]
        {
            let row = try SemanticTableEvidenceTests.row(value)
            let fact = try SemanticTableEvidenceTests.location(
                target: .row(row)
            )
            let evidence = try SemanticTableEvidenceTests.evidence([fact])
            #expect(SourcedSemanticTable(
                table: table,
                evidence: evidence
            ) == nil)
        }
    }

    @Test("out-of-bounds cell targets are refused")
    func outOfBoundsCellTargetsAreRefused() throws
    {
        let row0 = try SemanticTableEvidenceTests.row(0)
        let row1 = try SemanticTableEvidenceTests.row(1)
        let cell0 = try SemanticTableEvidenceTests.cell(0)
        let cell1 = try SemanticTableEvidenceTests.cell(1)
        let cases = [
            (Self.table(bodyRows: [[]]), row0, cell0),
            (
                Self.table(bodyRows: [[Self.regularCell()]]),
                row0,
                cell1
            ),
            (
                Self.table(bodyRows: [[Self.regularCell()]]),
                row1,
                cell0
            )
        ]
        for (table, row, cell) in cases
        {
            let fact = try SemanticTableEvidenceTests.confidence(
                target: .cell(row: row, cell: cell)
            )
            let evidence = try SemanticTableEvidenceTests.evidence([fact])
            #expect(SourcedSemanticTable(
                table: table,
                evidence: evidence
            ) == nil)
        }
    }
}
