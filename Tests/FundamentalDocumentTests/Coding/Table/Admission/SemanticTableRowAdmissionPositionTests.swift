import Testing

@testable import FundamentalDocument

extension SemanticTableRowAdmissionTests
{
    @Test("nested evidence retains exact normalized positions")
    func nestedEvidenceRetainsExactNormalizedPositions() throws
    {
        let admission = try Self.admit(
            Self.row(cells: [
                Self.cell(
                    "First",
                    sourceLocation: "  cell:0  ",
                    confidence: 0.25
                ),
                Self.cell(
                    "Second",
                    sourceLocation: " \t ",
                    confidence: 0.75
                )
            ]),
            role: .body,
            rowValue: 4
        )
        let row = try #require(SemanticTableRowIndex(4))
        let first = try #require(SemanticTableCellIndex(0))
        let second = try #require(SemanticTableCellIndex(1))
        let firstTarget = SemanticTableEvidenceTarget.cell(
            row: row,
            cell: first
        )
        let secondTarget = SemanticTableEvidenceTarget.cell(
            row: row,
            cell: second
        )
        let firstConfidence = try #require(
            SemanticTableConfidence(0.25)
        )
        let secondConfidence = try #require(
            SemanticTableConfidence(0.75)
        )
        let location = try #require(
            SemanticTableSourceLocation("  cell:0  ")
        )
        let repair = try #require(SemanticTableRepair(
            target: secondTarget,
            kind: .blankSourceLocationDiscarded
        ))

        #expect(admission.evidence == [
            .confidence(
                target: .cell(row: row, cell: first),
                confidence: firstConfidence
            ),
            .sourceLocation(
                target: firstTarget,
                location: location
            ),
            .confidence(
                target: .cell(row: row, cell: second),
                confidence: secondConfidence
            ),
            .repair(repair)
        ])
    }
}
