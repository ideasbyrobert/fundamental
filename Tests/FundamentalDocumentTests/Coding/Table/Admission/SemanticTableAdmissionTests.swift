import Testing

@testable import FundamentalDocument

@Suite("Semantic table admission")
struct SemanticTableAdmissionTests
{
    static func row(
        _ text: String,
        isHeader: Bool = false,
        sourceLocation: String? = nil,
        confidence: Double = 1
    ) -> LegacySemanticTableRow
    {
        LegacySemanticTableRow(
            cells: [LegacySemanticTableCell(
                runs: [SemanticRun(text: text)],
                isHeader: isHeader,
                rowSpan: 1,
                columnSpan: 1,
                alignment: .unspecified,
                sourceLocation: nil,
                confidence: confidence
            )],
            sourceLocation: sourceLocation
        )
    }
    static func table(
        rows: [LegacySemanticTableRow] = [],
        headerRowCount: Int = 0,
        columnAlignments: [SemanticTableColumnAlignment] = [],
        caption: [SemanticRun]? = nil,
        sourceLocation: String? = nil,
        confidence: Double = 1
    ) -> LegacySemanticTable
    {
        LegacySemanticTable(
            rows: rows,
            headerRowCount: headerRowCount,
            columnAlignments: columnAlignments,
            caption: caption,
            sourceLocation: sourceLocation,
            confidence: confidence
        )
    }
    static func admit(
        _ legacy: LegacySemanticTable
    ) throws -> (
        table: SemanticTable,
        evidence: [SemanticTableEvidenceFact]
    )
    {
        let sourced = try sourced(legacy)
        return (sourced.table, sourced.evidence.facts)
    }
    static func sourced(
        _ legacy: LegacySemanticTable
    ) throws -> SourcedSemanticTable
    {
        let admission = try #require(
            SemanticTableAdmissionAdapter.admit(legacy)
        )
        let sourced: SourcedSemanticTable?
        switch admission.record
        {
        case .semantic:
            sourced = nil
        case let .sourced(table):
            sourced = table
        }
        return try #require(sourced)
    }
    @Test("normalized row order and alignments survive admission")
    func normalizedRowOrderAndAlignmentsSurviveAdmission() throws
    {
        let admission = try Self.sourced(Self.table(
            rows: [
                Self.row("Header", isHeader: true),
                Self.row("First"),
                Self.row("Second")
            ],
            headerRowCount: 1,
            columnAlignments: [
                .leading,
                .unspecified,
                .leading
            ]
        ))
        #expect(admission.table.content.headerRows
            .flatMap(\.cells).map(\.plainText) == ["Header"])
        #expect(admission.table.content.bodyRows
            .flatMap(\.cells).map(\.plainText) == ["First", "Second"])
        #expect(admission.table.content.columnAlignments == [
            .leading,
            .unspecified,
            .leading
        ])
    }
}
