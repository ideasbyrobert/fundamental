import Testing

@testable import FundamentalRaster

@Suite("Raster empty-track rule evidence")
struct RasterEmptyTrackRuleTests
{
    @MainActor
    @Test("zero-row columns own their internal boundary")
    func zeroRows() throws
    {
        let layout = try RasterFixture.layout([
            RasterFixture.zeroRowTable()
        ], width: 360)
        let raster = try RasterFixture.snapshot(
            RasterFixture.viewport(layout)
        )
        let rules = ruleFills(raster)
        #expect(rules.count == 5)
        let columns = raster.interactionMap.regions.filter
        {
            guard case .columnTrack = $0.content else { return false }
            return true
        }.sorted { $0.frame.minX < $1.frame.minX }
        #expect(rules.contains
        {
            $0.logicalBounds.minX == columns[1].frame.minX
                && $0.logicalBounds.size.height > 1
        })
    }

    @MainActor
    @Test("empty rows and columns retain segmented internal rules")
    func emptyRows() throws
    {
        let layout = try RasterFixture.layout([
            RasterFixture.emptyRowTable()
        ], width: 360)
        let raster = try RasterFixture.snapshot(
            RasterFixture.viewport(layout)
        )
        let rules = ruleFills(raster)
        #expect(rules.count == 10)
        for first in rules.indices
        {
            for second in rules.indices where second > first
            {
                #expect(rules[first].logicalBounds.intersection(
                    rules[second].logicalBounds
                ) == nil)
            }
        }
    }

    @MainActor
    @Test("zero padding rows remain resident and rasterized")
    func zeroPadding() throws
    {
        let layout = try RasterFixture.layout(
            [RasterFixture.emptyRowTable()],
            width: 360,
            rowSpacing: 0,
            cellPadding: 0
        )
        let viewport = try RasterFixture.viewport(layout)
        let raster = try RasterFixture.snapshot(viewport)
        let rows = raster.interactionMap.regions.filter
        {
            guard case .rowTrack = $0.content else { return false }
            return true
        }
        #expect(rows.count == 2)
        #expect(rows.allSatisfy { $0.frame.size.height > 0 })
        #expect(!ruleFills(raster).isEmpty)
    }

    private func ruleFills(_ snapshot: RasterSnapshot) -> [RasterFill]
    {
        snapshot.marks.compactMap
        {
            guard case let .fill(fill) = $0,
                  fill.role == .tableRule
            else
            {
                return nil
            }
            return fill
        }
    }
}
