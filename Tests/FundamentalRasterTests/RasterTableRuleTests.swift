import Testing

@testable import FundamentalRaster

@Suite("Raster table rule ownership")
struct RasterTableRuleTests
{
    @MainActor
    @Test("cell boundaries respect spans and own every outer edge")
    func spanningCell() throws
    {
        let layout = try RasterFixture.layout([
            RasterFixture.table()
        ], width: 360)
        let raster = try RasterFixture.snapshot(
            RasterFixture.viewport(layout)
        )
        let regions = raster.interactionMap.regions
        let table = try #require(regions.first
        {
            $0.role == .table
        })
        let header = try #require(regions.first
        {
            guard case let .cell(cell) = $0.content else { return false }
            return cell.rowSpan == 1 && cell.columnSpan == 2
        })
        let rules: [RasterRectangle] = raster.marks.compactMap
        {
            guard case let .fill(fill) = $0,
                  fill.role == .tableRule
            else
            {
                return nil
            }
            return fill.logicalBounds
        }
        #expect(rules.contains { $0.minX == table.frame.minX })
        #expect(rules.contains { $0.maxX == table.frame.maxX })
        #expect(rules.contains { $0.minY == table.frame.minY })
        #expect(rules.contains { $0.maxY == table.frame.maxY })
        let internalVertical = rules.filter
        {
            $0.size.width <= 1
                && $0.minX > table.frame.minX
                && $0.maxX < table.frame.maxX
        }
        #expect(!internalVertical.isEmpty)
        #expect(internalVertical.allSatisfy
        {
            $0.minY >= header.frame.maxY
        })
        let firstRule = try #require(raster.marks.firstIndex
        {
            guard case let .fill(fill) = $0 else { return false }
            return fill.role == .tableRule
        })
        let lastHeader = try #require(raster.marks.lastIndex
        {
            guard case let .fill(fill) = $0 else { return false }
            return fill.role == .headerBackground
        })
        #expect(lastHeader < firstRule)
    }
}
