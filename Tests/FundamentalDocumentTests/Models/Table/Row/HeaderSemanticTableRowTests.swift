import Testing

@testable import FundamentalDocument

@Suite("A header semantic table row")
struct HeaderSemanticTableRowTests
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
        let row = HeaderSemanticTableRow(cells: cells)

        #expect(row.cells == cells)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let original = HeaderSemanticTableRow(cells: [])
        let changed = HeaderSemanticTableRow(cells: [
            .regular(RegularSemanticTableCell(
                runs: [SemanticRun(text: "Changed")]
            ))
        ])

        #expect(original != changed)
        #expect(original.cells.isEmpty)
    }
}
