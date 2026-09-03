import Testing

@testable import FundamentalRaster

@Suite("Raster table structure")
struct RasterTableStructureTests
{
    @MainActor
    @Test("region tracks cells captions and nested lines remain bounded")
    func structure() throws
    {
        let layout = try RasterFixture.layout([
            RasterFixture.table()
        ], width: 360)
        let viewport = try RasterFixture.viewport(layout)
        let raster = try RasterFixture.snapshot(viewport)
        let regions = raster.interactionMap.regions
        #expect(regions.contains { $0.role == .table })
        #expect(regions.contains { $0.role == .caption })
        #expect(regions.contains { $0.role == .headerRow(0) })
        #expect(regions.contains { $0.role == .bodyRow(1) })
        #expect(regions.contains { $0.role == .tableColumn(0) })
        let cells: [RasterTableCellGeometry] = regions.compactMap
        {
            guard case let .cell(value) = $0.content else { return nil }
            return value
        }
        #expect(cells.contains
        {
            $0.rowSpan == 1 && $0.columnSpan == 2
        })
        #expect(cells.contains
        {
            $0.projectedAlignment == .unspecified
                && $0.resolvedAlignment == .leading
        })
        let roles: [RasterFillRole] = raster.marks.compactMap
        {
            guard case let .fill(fill) = $0 else { return nil }
            return fill.role
        }
        #expect(roles.contains(.tableBackground))
        #expect(roles.contains(.headerBackground))
        #expect(roles.contains(.tableRule))
    }

    @MainActor
    @Test("every mark resolves to exactly one interaction resident")
    func anchorResolution() throws
    {
        let layout = try RasterFixture.layout([
            RasterFixture.table()
        ], width: 360)
        let raster = try RasterFixture.snapshot(
            RasterFixture.viewport(layout)
        )
        let identifiers = raster.interactionMap.regions
            .map(\.residentID)
        #expect(Set(identifiers).count == identifiers.count)
        for mark in raster.marks
        {
            #expect(identifiers.filter
            {
                $0 == mark.residentID
            }.count == 1)
        }
    }
}
