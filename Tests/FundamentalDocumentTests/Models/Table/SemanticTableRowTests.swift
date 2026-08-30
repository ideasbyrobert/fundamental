import Testing

@testable import FundamentalDocument

@Suite("A semantic table row")
struct SemanticTableRowTests
{
    @Test("minimal initialization uses the exact default")
    func minimalInitializationUsesDefault()
    {
        let row = SemanticTableRow(cells: [])

        #expect(row.cells.isEmpty)
        #expect(row.sourceLocation == nil)
    }

    @Test("full initialization preserves cell order and source location")
    func fullInitializationPreservesCellsAndSourceLocation()
    {
        let cells = [
            SemanticTableCell(
                runs: [SemanticRun(text: "First")]
            ),
            SemanticTableCell(
                runs: [SemanticRun(text: "Second")],
                isHeader: true
            )
        ]
        let row = SemanticTableRow(
            cells: cells,
            sourceLocation: "table:2"
        )

        #expect(row.cells == cells)
        #expect(row.sourceLocation == "table:2")
    }

    @Test("every stored field remains mutable")
    func everyStoredFieldRemainsMutable()
    {
        let cells = [
            SemanticTableCell(
                runs: [SemanticRun(text: "Changed")]
            )
        ]
        var row = SemanticTableRow(cells: [])

        row.cells = cells
        row.sourceLocation = "table:3"

        #expect(row.cells == cells)
        #expect(row.sourceLocation == "table:3")
    }

    @Test("equality observes every stored field")
    func equalityObservesEveryStoredField()
    {
        let row = SemanticTableRow(
            cells: [
                SemanticTableCell(
                    runs: [SemanticRun(text: "Body")]
                )
            ],
            sourceLocation: "table:1"
        )
        let identical = SemanticTableRow(
            cells: row.cells,
            sourceLocation: row.sourceLocation
        )
        var changed = row

        #expect(row == identical)

        changed.cells = []
        #expect(changed != row)

        changed = row
        changed.sourceLocation = nil
        #expect(changed != row)
    }
}
