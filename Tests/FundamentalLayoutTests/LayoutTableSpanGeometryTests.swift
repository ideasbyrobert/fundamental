import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Native table span geometry")
struct LayoutTableSpanGeometryTests
{
    @MainActor
    @Test("spanning cells occupy their complete track rectangles")
    func spanFrames() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: false)
        )
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 360)
        )
        let grid = try #require(snapshot.grids.first)
        let spacing = snapshot.lineage.specification.parameters
        let wide = try #require(grid.cells.first
        {
            $0.sourceRow == 0 && $0.sourceCell == 1
        })
        let wideTracks = grid.columnTracks[1 ... 2]
        let expectedWidth = wideTracks.reduce(0)
        {
            $0 + $1.extent
        } + spacing.columnSpacing
        #expect(abs(wide.frame.size.width - expectedWidth) < 0.001)
        let tall = try #require(grid.cells.first
        {
            $0.sourceRow == 1 && $0.sourceCell == 0
        })
        let tallTracks = grid.rowTracks[1 ... 2]
        let expectedHeight = tallTracks.reduce(0)
        {
            $0 + $1.extent
        } + spacing.rowSpacing
        #expect(abs(tall.frame.size.height - expectedHeight) < 0.001)
        let shifted = try #require(grid.cells.first
        {
            $0.sourceRow == 2 && $0.sourceCell == 0
        })
        #expect(shifted.columnTrack == 1)
    }
}
