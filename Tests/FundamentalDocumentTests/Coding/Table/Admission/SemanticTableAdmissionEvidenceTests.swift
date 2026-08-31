import Testing

@testable import FundamentalDocument

extension SemanticTableAdmissionTests
{
    @Test("table locations remain missing blank or exact")
    func tableLocationsRemainMissingBlankOrExact() throws
    {
        let missing = try Self.admit(Self.table())
        let blank = try Self.admit(Self.table(
            sourceLocation: " \t\n "
        ))
        let exactValue = "  table:2  "
        let exact = try Self.admit(Self.table(
            sourceLocation: exactValue
        ))
        let blankRepair = try #require(SemanticTableRepair(
            target: .table,
            kind: .blankSourceLocationDiscarded
        ))
        let location = try #require(
            SemanticTableSourceLocation(exactValue)
        )
        #expect(!missing.evidence.contains(.repair(blankRepair)))
        #expect(blank.evidence.contains(.repair(blankRepair)))
        #expect(exact.evidence.contains(.sourceLocation(
            target: .table,
            location: location
        )))
    }
    @Test("valid confidence and nested evidence retain exact targets")
    func validConfidenceAndNestedEvidenceRetainExactTargets() throws
    {
        for value in [0.0, 0.25, 1.0]
        {
            let admission = try Self.admit(Self.table(
                rows: [
                    Self.row(
                        "Header",
                        isHeader: true,
                        sourceLocation: "  header:0  ",
                        confidence: 0.5
                    ),
                    Self.row(
                        "Body",
                        sourceLocation: "  body:1  ",
                        confidence: 0.75
                    )
                ],
                headerRowCount: 1,
                confidence: value
            ))
            let tableConfidence = try #require(
                SemanticTableConfidence(value)
            )
            let headerConfidence = try #require(
                SemanticTableConfidence(0.5)
            )
            let cellConfidence = try #require(
                SemanticTableConfidence(0.75)
            )
            let headerLocation = try #require(
                SemanticTableSourceLocation("  header:0  ")
            )
            let bodyLocation = try #require(
                SemanticTableSourceLocation("  body:1  ")
            )
            let headerRow = try #require(SemanticTableRowIndex(0))
            let bodyRow = try #require(SemanticTableRowIndex(1))
            let cell = try #require(SemanticTableCellIndex(0))
            #expect(admission.evidence.contains(.confidence(
                target: .table,
                confidence: tableConfidence
            )))
            #expect(admission.evidence.contains(.sourceLocation(
                target: .row(headerRow),
                location: headerLocation
            )))
            #expect(admission.evidence.contains(.sourceLocation(
                target: .row(bodyRow),
                location: bodyLocation
            )))
            #expect(admission.evidence.contains(.confidence(
                target: .cell(row: headerRow, cell: cell),
                confidence: headerConfidence
            )))
            #expect(admission.evidence.contains(.confidence(
                target: .cell(row: bodyRow, cell: cell),
                confidence: cellConfidence
            )))
        }
    }
}
