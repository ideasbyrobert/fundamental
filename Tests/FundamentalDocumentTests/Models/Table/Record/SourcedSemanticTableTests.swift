import Testing

@testable import FundamentalDocument

@Suite("A sourced semantic table")
struct SourcedSemanticTableTests
{
    static func regularCell(
        _ text: String = "Cell"
    ) -> SemanticTableCell
    {
        .regular(RegularSemanticTableCell(
            runs: [SemanticRun(text: text)]
        ))
    }

    static func spanningCell(
        rowCount: Int,
        columnCount: Int
    ) throws -> SemanticTableCell
    {
        let extent = try #require(SemanticTableCellExtent(
            rowCount: rowCount,
            columnCount: columnCount
        ))
        return .spanning(SpanningSemanticTableCell(
            runs: [SemanticRun(text: "Cell")],
            extent: extent
        ))
    }

    static func table(
        headerRows: [[SemanticTableCell]] = [],
        bodyRows: [[SemanticTableCell]] = []
    ) -> SemanticTable
    {
        let content = SemanticTableContent(
            headerRows: headerRows.map
            {
                HeaderSemanticTableRow(cells: $0)
            },
            bodyRows: bodyRows.map
            {
                BodySemanticTableRow(cells: $0)
            },
            columnAlignments: []
        )
        return .regular(RegularSemanticTable(content: content))
    }

    static func sourced(
        table: SemanticTable,
        facts: [SemanticTableEvidenceFact]
    ) throws -> SourcedSemanticTable
    {
        let evidence = try SemanticTableEvidenceTests.evidence(facts)
        return try #require(SourcedSemanticTable(
            table: table,
            evidence: evidence
        ))
    }

    @Test("construction preserves required table and evidence")
    func constructionPreservesRequiredTableAndEvidence() throws
    {
        let table = Self.table()
        let fact = try SemanticTableEvidenceTests.confidence(
            target: .table
        )
        let sourced = try Self.sourced(
            table: table,
            facts: [fact]
        )

        #expect(sourced.table == table)
        #expect(sourced.evidence.facts == [fact])
    }

    @Test("reconstruction leaves original sourced table unchanged")
    func reconstructionLeavesOriginalSourcedTableUnchanged() throws
    {
        let fact = try SemanticTableEvidenceTests.confidence(
            target: .table
        )
        let original = try Self.sourced(
            table: Self.table(),
            facts: [fact]
        )
        let changed = try Self.sourced(
            table: Self.table(bodyRows: [[Self.regularCell()]]),
            facts: [fact]
        )

        #expect(original != changed)
        #expect(original.table == Self.table())
    }
}
