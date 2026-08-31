import Testing

@testable import FundamentalDocument

extension SemanticTableTests
{
    @Test("header row count clamps only at construction")
    func headerRowCountClampsOnlyAtConstruction()
    {
        let rows = [
            SemanticTableRow(cells: [
                .regular(RegularSemanticTableCell(runs: []))
            ]),
            SemanticTableRow(cells: [
                .regular(RegularSemanticTableCell(runs: []))
            ])
        ]
        let negative = SemanticTable(
            rows: rows,
            headerRowCount: -2
        )
        let zero = SemanticTable(
            rows: rows,
            headerRowCount: 0
        )
        let within = SemanticTable(
            rows: rows,
            headerRowCount: 1
        )
        let boundary = SemanticTable(
            rows: rows,
            headerRowCount: 2
        )
        let excessive = SemanticTable(
            rows: rows,
            headerRowCount: 3
        )
        let empty = SemanticTable(
            rows: [],
            headerRowCount: 1
        )
        var mutated = within

        mutated.headerRowCount = -1

        #expect(negative.headerRowCount == 0)
        #expect(zero.headerRowCount == 0)
        #expect(within.headerRowCount == 1)
        #expect(boundary.headerRowCount == 2)
        #expect(excessive.headerRowCount == 2)
        #expect(empty.headerRowCount == 0)
        #expect(mutated.headerRowCount == -1)
    }
}
