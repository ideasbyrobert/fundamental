import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    @MainActor
    @Test("spanning cell extents equal their eager native frames")
    func spanningTable() throws
    {
        let result = try product(
            .table(try LayoutFixture.table(captioned: false)),
            width: 360
        )
        let grid = try #require(result.snapshot.grids.first)
        let spanning = grid.cells.filter
        {
            $0.rowSpan > 1 || $0.columnSpan > 1
        }
        #expect(spanning.count == 2)
        for cell in spanning
        {
            #expect(result.measurement.extents.contains
            {
                $0.content == .tableCell && $0.frame == cell.frame
            })
        }
        expectParity(result.measurement, result.snapshot)
    }

    @MainActor
    @Test("empty tables retain only structural font truth")
    func emptyTableMeasurement() throws
    {
        let blocks = [try emptyTable(), try emptyRowTable()]
        for (index, block) in blocks.enumerated()
        {
            let result = try product(block, width: 320)
            let table = try #require(tableFacts(result.measurement))
            #expect(table.rowCount == [0, 2][index])
            #expect(table.cellCount == 0)
            #expect(result.measurement.contentFonts.isEmpty)
            #expect(result.measurement.resolvedFonts == [
                table.structuralFont
            ])
            #expect(result.measurement.extents.contains
            {
                $0.content == .tableRegion
            })
            #expect(result.measurement.extents.contains
            {
                $0.content == .tableRule
            })
            #expect(result.measurement.extents.filter
            {
                $0.content == .tableRowTrack
            }.count == [0, 2][index])
            expectParity(result.measurement, result.snapshot)
        }
    }
}
