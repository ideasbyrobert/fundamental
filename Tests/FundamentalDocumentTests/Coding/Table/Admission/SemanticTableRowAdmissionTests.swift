import Testing

@testable import FundamentalDocument

@Suite("Semantic table row admission")
struct SemanticTableRowAdmissionTests
{
    static func cell(
        _ text: String,
        isHeader: Bool = false,
        sourceLocation: String? = nil,
        confidence: Double = 1
    ) -> LegacySemanticTableCell
    {
        LegacySemanticTableCell(
            runs: [SemanticRun(text: text)],
            isHeader: isHeader,
            rowSpan: 1,
            columnSpan: 1,
            alignment: .unspecified,
            sourceLocation: sourceLocation,
            confidence: confidence
        )
    }

    static func row(
        cells: [LegacySemanticTableCell],
        sourceLocation: String? = nil
    ) -> LegacySemanticTableRow
    {
        LegacySemanticTableRow(
            cells: cells,
            sourceLocation: sourceLocation
        )
    }

    static func admit(
        _ legacy: LegacySemanticTableRow,
        role: SemanticTableRowAdmissionRole,
        rowValue: Int = 2
    ) throws -> SemanticTableRowAdmission
    {
        let rowIndex = try #require(
            SemanticTableRowIndex(rowValue)
        )
        return try #require(
            SemanticTableRowAdmissionAdapter.admit(
                legacy,
                rowIndex: rowIndex,
                role: role
            )
        )
    }

    @Test("roles produce only their matching canonical forms")
    func rolesProduceOnlyMatchingCanonicalForms() throws
    {
        let legacy = Self.row(cells: [])
        let header = try Self.admit(legacy, role: .header)
        let body = try Self.admit(legacy, role: .body)

        guard case .header = header.row,
              case .body = body.row
        else
        {
            Issue.record("Expected matching row forms")
            return
        }
    }

    @Test("cell order and canonical payloads survive admission")
    func cellOrderAndCanonicalPayloadsSurviveAdmission() throws
    {
        let admission = try Self.admit(
            Self.row(cells: [
                Self.cell("First"),
                Self.cell("Second")
            ]),
            role: .body
        )

        #expect(admission.row.cells.map(\.plainText) == [
            "First",
            "Second"
        ])
    }
}
