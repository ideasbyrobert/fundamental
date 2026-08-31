import Testing

@testable import FundamentalDocument

extension SemanticTableTests
{
    @Test("every stored field remains mutable")
    func everyStoredFieldRemainsMutable()
    {
        let rows = [SemanticTableRow(cells: [
            .regular(RegularSemanticTableCell(runs: []))
        ])]
        let caption = [SemanticRun(text: "Changed")]
        var table = SemanticTable(rows: [])

        table.rows = rows
        table.headerRowCount = 2
        table.columnAlignments = [.center]
        table.caption = caption
        table.sourceLocation = "table:3"
        table.confidence = 0.5

        #expect(table.rows == rows)
        #expect(table.headerRowCount == 2)
        #expect(table.columnAlignments == [.center])
        #expect(table.caption == caption)
        #expect(table.sourceLocation == "table:3")
        #expect(table.confidence == 0.5)
    }

    @Test("equality observes every stored field")
    func equalityObservesEveryStoredField()
    {
        let table = SemanticTable(
            rows: [SemanticTableRow(cells: [
                .regular(RegularSemanticTableCell(runs: []))
            ])],
            headerRowCount: 1,
            columnAlignments: [.leading],
            caption: [SemanticRun(text: "Caption")],
            sourceLocation: "table:1",
            confidence: 0.75
        )
        var changed = table

        #expect(changed == table)

        changed.rows = []
        #expect(changed != table)

        changed = table
        changed.headerRowCount = 0
        #expect(changed != table)

        changed = table
        changed.columnAlignments = []
        #expect(changed != table)

        changed = table
        changed.caption = nil
        #expect(changed != table)

        changed = table
        changed.sourceLocation = nil
        #expect(changed != table)

        changed = table
        changed.confidence = 0.5
        #expect(changed != table)
    }
}
