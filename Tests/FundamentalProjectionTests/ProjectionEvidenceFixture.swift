import Testing

@testable import FundamentalDocument

extension ProjectionFixture
{
    static func evidence() throws -> SemanticTableEvidence
    {
        let rowZero = try #require(SemanticTableRowIndex(0))
        let rowOne = try #require(SemanticTableRowIndex(1))
        let cellZero = try #require(SemanticTableCellIndex(0))
        let tableLocation = try location("table")
        let rowLocation = try location("row")
        let cellLocation = try location("cell")
        let confidence = try #require(SemanticTableConfidence(0.75))
        let facts: [SemanticTableEvidenceFact] = [
            .sourceLocation(target: .table, location: tableLocation),
            .sourceLocation(target: .row(rowZero), location: rowLocation),
            .sourceLocation(
                target: .cell(row: rowOne, cell: cellZero),
                location: cellLocation
            ),
            .confidence(target: .table, confidence: confidence),
            .confidence(
                target: .cell(row: rowZero, cell: cellZero),
                confidence: confidence
            ),
            try repair(.table, .headerRowCountClamped),
            try repair(
                .cell(row: rowZero, cell: cellZero),
                .nonpositiveRowSpanNormalizedToOne
            ),
            try repair(
                .cell(row: rowZero, cell: cellZero),
                .nonpositiveColumnSpanNormalizedToOne
            ),
            try repair(
                .cell(row: rowOne, cell: cellZero),
                .contradictoryCellHeaderFlagDiscarded
            ),
            try repair(.row(rowOne), .blankSourceLocationDiscarded)
        ]
        return try #require(SemanticTableEvidence(
            firstFact: facts[0],
            remainingFacts: Array(facts.dropFirst())
        ))
    }

    private static func location(
        _ value: String
    ) throws -> SemanticTableSourceLocation
    {
        try #require(SemanticTableSourceLocation(value))
    }

    private static func repair(
        _ target: SemanticTableEvidenceTarget,
        _ kind: SemanticTableRepairKind
    ) throws -> SemanticTableEvidenceFact
    {
        .repair(try #require(SemanticTableRepair(
            target: target,
            kind: kind
        )))
    }
}
