import Testing

@testable import FundamentalDocument

extension SemanticTableRowAdmissionTests
{
    @Test("row locations remain missing blank or exact")
    func rowLocationsRemainMissingBlankOrExact() throws
    {
        let missing = try Self.admit(
            Self.row(cells: [Self.cell("Body")]),
            role: .body
        )
        let blank = try Self.admit(
            Self.row(
                cells: [Self.cell("Body")],
                sourceLocation: " \t\n "
            ),
            role: .body
        )
        let exactValue = "  row:2  "
        let exact = try Self.admit(
            Self.row(
                cells: [Self.cell("Body")],
                sourceLocation: exactValue
            ),
            role: .body
        )
        let row = try #require(SemanticTableRowIndex(2))
        let repair = try #require(SemanticTableRepair(
            target: .row(row),
            kind: .blankSourceLocationDiscarded
        ))
        let location = try #require(
            SemanticTableSourceLocation(exactValue)
        )

        #expect(missing.evidence.count == 1)
        #expect(blank.evidence.contains(.repair(repair)))
        #expect(exact.evidence.contains(.sourceLocation(
            target: .row(row),
            location: location
        )))
    }

    @Test("matching claims stay silent and contradictions are exact")
    func matchingClaimsStaySilentAndContradictionsAreExact() throws
    {
        let header = try Self.admit(
            Self.row(cells: [
                Self.cell("Match", isHeader: true),
                Self.cell("Conflict", isHeader: false)
            ]),
            role: .header,
            rowValue: 5
        )
        let body = try Self.admit(
            Self.row(cells: [
                Self.cell("Match", isHeader: false),
                Self.cell("Conflict", isHeader: true)
            ]),
            role: .body,
            rowValue: 6
        )

        try expectOneContradiction(in: header, rowValue: 5)
        try expectOneContradiction(in: body, rowValue: 6)
    }

    private func expectOneContradiction(
        in admission: SemanticTableRowAdmission,
        rowValue: Int
    ) throws
    {
        let row = try #require(SemanticTableRowIndex(rowValue))
        let cell = try #require(SemanticTableCellIndex(1))
        let repair = try #require(SemanticTableRepair(
            target: .cell(row: row, cell: cell),
            kind: .contradictoryCellHeaderFlagDiscarded
        ))
        let repairs = admission.evidence.filter
        {
            if case .repair = $0
            {
                return true
            }
            return false
        }

        #expect(repairs == [.repair(repair)])
    }
}
