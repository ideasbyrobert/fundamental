import Testing

@testable import FundamentalDocument

@Suite("Semantic table cell admission")
struct SemanticTableCellAdmissionTests
{
    static func legacy(
        runs: [SemanticRun] = [],
        isHeader: Bool = false,
        rowSpan: Int = 1,
        columnSpan: Int = 1,
        alignment: SemanticTableColumnAlignment = .unspecified,
        sourceLocation: String? = nil,
        confidence: Double = 1
    ) -> LegacySemanticTableCell
    {
        LegacySemanticTableCell(
            runs: runs,
            isHeader: isHeader,
            rowSpan: rowSpan,
            columnSpan: columnSpan,
            alignment: alignment,
            sourceLocation: sourceLocation,
            confidence: confidence
        )
    }

    static func indices() throws -> (
        SemanticTableRowIndex,
        SemanticTableCellIndex
    )
    {
        (
            try #require(SemanticTableRowIndex(2)),
            try #require(SemanticTableCellIndex(3))
        )
    }

    static func admit(
        _ legacy: LegacySemanticTableCell
    ) throws -> SemanticTableCellAdmission
    {
        let (row, cell) = try indices()
        return try #require(
            SemanticTableCellAdmissionAdapter.admit(
                legacy,
                rowIndex: row,
                cellIndex: cell
            )
        )
    }

    @Test("one-by-one and spanning payloads admit exact forms")
    func oneByOneAndSpanningPayloadsAdmitExactForms() throws
    {
        let regular = try Self.admit(Self.legacy())
        let spanning = try Self.admit(
            Self.legacy(rowSpan: 2, columnSpan: 3)
        )

        #expect(regular.cell.rowCount == 1)
        #expect(regular.cell.columnCount == 1)
        #expect(spanning.cell.rowCount == 2)
        #expect(spanning.cell.columnCount == 3)
        guard case .regular = regular.cell,
              case .spanning = spanning.cell
        else
        {
            Issue.record("Expected regular and spanning forms")
            return
        }
    }

    @Test("legacy header claims survive outside canonical cells")
    func legacyHeaderClaimsSurviveOutsideCanonicalCells() throws
    {
        let header = try Self.admit(Self.legacy(isHeader: true))
        let body = try Self.admit(Self.legacy(isHeader: false))

        #expect(header.legacyHeaderClaim)
        #expect(body.legacyHeaderClaim == false)
    }
}
