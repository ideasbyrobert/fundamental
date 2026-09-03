import Testing

@testable import FundamentalDocument

extension SourcedSemanticTableTests
{
    static func spanRepair(
        _ kind: SemanticTableRepairKind
    ) throws -> SemanticTableEvidenceFact
    {
        let row = try SemanticTableEvidenceTests.row(0)
        let cell = try SemanticTableEvidenceTests.cell(0)
        return try SemanticTableEvidenceTests.repair(
            target: .cell(row: row, cell: cell),
            kind: kind
        )
    }
    @Test("row-span repair requires one occupied row")
    func rowSpanRepairRequiresOneOccupiedRow() throws
    {
        let table = try Self.table(bodyRows: [[
            try Self.spanningCell(rowCount: 2, columnCount: 1)
        ], []])
        let fact = try Self.spanRepair(
            .nonpositiveRowSpanNormalizedToOne
        )
        let evidence = try SemanticTableEvidenceTests.evidence([fact])
        #expect(SourcedSemanticTable(
            table: table,
            evidence: evidence
        ) == nil)
    }
    @Test("column-span repair requires one occupied column")
    func columnSpanRepairRequiresOneOccupiedColumn() throws
    {
        let table = try Self.table(bodyRows: [[
            try Self.spanningCell(rowCount: 1, columnCount: 2)
        ]])
        let fact = try Self.spanRepair(
            .nonpositiveColumnSpanNormalizedToOne
        )
        let evidence = try SemanticTableEvidenceTests.evidence([fact])
        #expect(SourcedSemanticTable(
            table: table,
            evidence: evidence
        ) == nil)
    }
    @Test("compatible span repairs remain admitted")
    func compatibleSpanRepairsRemainAdmitted() throws
    {
        let rowRepair = try Self.spanRepair(
            .nonpositiveRowSpanNormalizedToOne
        )
        let columnRepair = try Self.spanRepair(
            .nonpositiveColumnSpanNormalizedToOne
        )
        let cases = [
            (Self.regularCell(), [rowRepair, columnRepair]),
            (
                try Self.spanningCell(rowCount: 1, columnCount: 2),
                [rowRepair]
            ),
            (
                try Self.spanningCell(rowCount: 2, columnCount: 1),
                [columnRepair]
            )
        ]
        for (cell, facts) in cases
        {
            #expect(try Self.sourced(
                table: try Self.table(bodyRows: [[cell], []]),
                facts: facts
            ).evidence.facts == facts)
        }
    }
    @Test("one dimensions do not require span repairs")
    func oneDimensionsDoNotRequireSpanRepairs() throws
    {
        let row = try SemanticTableEvidenceTests.row(0)
        let cellIndex = try SemanticTableEvidenceTests.cell(0)
        let fact = try SemanticTableEvidenceTests.confidence(
            target: .cell(row: row, cell: cellIndex)
        )
        let cells = [
            Self.regularCell(),
            try Self.spanningCell(rowCount: 1, columnCount: 2),
            try Self.spanningCell(rowCount: 2, columnCount: 1)
        ]
        for cell in cells
        {
            #expect(try Self.sourced(
                table: try Self.table(bodyRows: [[cell], []]),
                facts: [fact]
            ).evidence.facts == [fact])
        }
    }
}
