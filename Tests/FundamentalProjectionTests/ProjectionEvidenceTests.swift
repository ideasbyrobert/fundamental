import Testing

@testable import FundamentalProjection

extension ProjectionProseTests
{
    func verifyEvidence(_ evidence: ProjectedTableEvidence)
    {
        #expect(evidence.facts == [
            .sourceLocation(
                target: .table,
                location: "table"
            ),
            .confidence(
                target: .table,
                value: 0.75
            ),
            .repair(
                target: .table,
                kind: .headerRowCountClamped
            ),
            .sourceLocation(
                target: .row(0),
                location: "row"
            ),
            .confidence(
                target: .cell(row: 0, cell: 0),
                value: 0.75
            ),
            .repair(
                target: .cell(row: 0, cell: 0),
                kind: .nonpositiveRowSpanNormalizedToOne
            ),
            .repair(
                target: .cell(row: 0, cell: 0),
                kind: .nonpositiveColumnSpanNormalizedToOne
            ),
            .repair(
                target: .row(1),
                kind: .blankSourceLocationDiscarded
            ),
            .sourceLocation(
                target: .cell(row: 1, cell: 0),
                location: "cell"
            ),
            .repair(
                target: .cell(row: 1, cell: 0),
                kind: .contradictoryCellHeaderFlagDiscarded
            )
        ])
    }
}
