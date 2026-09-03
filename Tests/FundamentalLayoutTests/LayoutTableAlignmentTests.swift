import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Native table alignment")
struct LayoutTableAlignmentTests
{
    @MainActor
    @Test("column alignment resolves unspecified cell geometry")
    func resolvedAlignment() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: false)
        )
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 360)
        )
        let grid = try #require(snapshot.grids.first)
        #expect(grid.frame.size.width == 360)
        let tail = try #require(grid.cells.first
        {
            $0.sourceRow == 1 && $0.sourceCell == 1
        })
        #expect(tail.projectedAlignment == .unspecified)
        #expect(tail.resolvedAlignment == .center)
        let line = try #require(grid.cellLines.first
        {
            $0.sourceRow == 1 && $0.sourceCell == 1
        })
        let left = line.line.frame.minX - tail.frame.minX
        let right = tail.frame.maxX - line.line.frame.maxX
        #expect(abs(left - right) < 0.001)
        let trailing = try #require(grid.cells.first
        {
            $0.sourceRow == 1 && $0.sourceCell == 0
        })
        #expect(trailing.resolvedAlignment == .trailing)
        let trailingLine = try #require(grid.cellLines.first
        {
            $0.sourceRow == 1 && $0.sourceCell == 0
        })
        let padding = snapshot.lineage.specification
            .parameters.cellPadding
        #expect(abs(
            trailing.frame.maxX - trailingLine.line.frame.maxX
                - padding
        ) < 0.001)
        let firstGlyph = try #require(
            line.line.glyphRuns.first?.firstGlyph
        )
        #expect(firstGlyph.position.x > tail.frame.minX + 5)
        #expect(line.line.firstCaretStop.position.x
            > tail.frame.minX + 5)
        let after = try #require(grid.cells.first
        {
            $0.sourceRow == 2 && $0.sourceCell == 0
        })
        #expect(after.rowTrack == 2)
        #expect(after.columnTrack == 1)
    }
}
