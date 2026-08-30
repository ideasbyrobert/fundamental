import Testing

@testable import FundamentalDocument

extension SemanticTableCellTests
{
    @Test("every stored field remains mutable")
    func everyStoredFieldRemainsMutable()
    {
        let runs = [SemanticRun(text: "Changed")]
        var cell = SemanticTableCell(runs: [])

        cell.runs = runs
        cell.isHeader = true
        cell.rowSpan = 0
        cell.columnSpan = -2
        cell.alignment = .center
        cell.sourceLocation = "table:4:2"
        cell.confidence = 0.5

        #expect(cell.runs == runs)
        #expect(cell.isHeader)
        #expect(cell.rowSpan == 0)
        #expect(cell.columnSpan == -2)
        #expect(cell.alignment == .center)
        #expect(cell.sourceLocation == "table:4:2")
        #expect(cell.confidence == 0.5)
    }

    @Test("equality observes every stored field")
    func equalityObservesEveryStoredField()
    {
        let cell = SemanticTableCell(
            runs: [SemanticRun(text: "Body")],
            isHeader: true,
            rowSpan: 2,
            columnSpan: 3,
            alignment: .leading,
            sourceLocation: "table:1:1",
            confidence: 0.75
        )
        let identical = SemanticTableCell(
            runs: [SemanticRun(text: "Body")],
            isHeader: true,
            rowSpan: 2,
            columnSpan: 3,
            alignment: .leading,
            sourceLocation: "table:1:1",
            confidence: 0.75
        )
        var changed = cell

        #expect(cell == identical)

        changed.runs = [SemanticRun(text: "Different")]
        #expect(changed != cell)

        changed = cell
        changed.isHeader = false
        #expect(changed != cell)

        changed = cell
        changed.rowSpan = 4
        #expect(changed != cell)

        changed = cell
        changed.columnSpan = 5
        #expect(changed != cell)

        changed = cell
        changed.alignment = .trailing
        #expect(changed != cell)

        changed = cell
        changed.sourceLocation = nil
        #expect(changed != cell)

        changed = cell
        changed.confidence = 0.5
        #expect(changed != cell)
    }
}
