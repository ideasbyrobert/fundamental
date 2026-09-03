import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

@Suite("Every native table cell source")
struct LayoutTableCellSourceTests
{
    @MainActor
    @Test("each laid cell line retains its semantic cell identity")
    func allCellSources() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: false)
        )
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 360)
        )
        let grid = try #require(snapshot.grids.first)
        let blockID = LayoutFixture.blockID(0)
        let expected = [
            (row: 0, cell: 0, count: 4),
            (row: 0, cell: 1, count: 4),
            (row: 1, cell: 0, count: 3),
            (row: 1, cell: 1, count: 4),
            (row: 2, cell: 0, count: 5)
        ]
        #expect(grid.cellLines.count == expected.count)
        for (line, item) in zip(grid.cellLines, expected)
        {
            #expect(line.sourceRow == item.row)
            #expect(line.sourceCell == item.cell)
            #expect(line.line.sourceSlices.first?.source == .cell(
                blockID: blockID,
                row: item.row,
                cell: item.cell,
                run: 0,
                range: ProjectedUTF16Range(0 ..< item.count)
            ))
        }
    }
}
