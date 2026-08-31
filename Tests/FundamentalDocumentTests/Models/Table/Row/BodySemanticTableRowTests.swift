import Testing

@testable import FundamentalDocument

@Suite("A body semantic table row")
struct BodySemanticTableRowTests
{
    @Test("initialization preserves immutable ordered cells")
    func initializationPreservesImmutableOrderedCells()
    {
        let cells: [SemanticTableCell] = [
            .regular(RegularSemanticTableCell(
                runs: [SemanticRun(text: "First")]
            )),
            .regular(RegularSemanticTableCell(
                runs: [SemanticRun(text: "Second")]
            ))
        ]
        let row = BodySemanticTableRow(cells: cells)

        #expect(row.cells == cells)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let original = BodySemanticTableRow(cells: [])
        let changed = BodySemanticTableRow(cells: [
            .regular(RegularSemanticTableCell(
                runs: [SemanticRun(text: "Changed")]
            ))
        ])

        #expect(original != changed)
        #expect(original.cells.isEmpty)
    }
}
