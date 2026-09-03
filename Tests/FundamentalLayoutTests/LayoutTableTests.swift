import Testing
@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection
@Suite("Native projected table layout")
struct LayoutTableTests
{
    @MainActor
    @Test("grid geometry preserves caption scope tracks and spans")
    func gridFacts() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: true)
        )
        let projection = try LayoutFixture.projection([block])
        let snapshot = try NativeTextKit2Layout().layout(
            projection,
            request: LayoutFixture.request(width: 360)
        )
        let grid = try #require(snapshot.grids.first)
        #expect(grid.source == projection.firstBlock.source)
        #expect(grid.columnTracks.map(\.alignment)
            == [.leading, .center, .trailing])
        #expect(grid.rowTracks.map(\.scope)
            == [.header, .body, .body])
        #expect(grid.captionLines.map(\.text).joined() == "C😀")
        let wide = try #require(grid.cells.first
        {
            $0.sourceRow == 0 && $0.sourceCell == 1
        })
        #expect(wide.columnTrack == 1)
        #expect(wide.columnSpan == 2)
        #expect(wide.rowSpan == 1)
        let tall = try #require(grid.cells.first
        {
            $0.sourceRow == 1 && $0.sourceCell == 0
        })
        #expect(tall.scope == .body)
        #expect(tall.rowSpan == 2)
        #expect(tall.columnSpan == 1)
        #expect(grid.cellLines.map(\.line.text).joined()
            .contains("B😀"))
        let captionSlices = grid.captionLines.flatMap(\.sourceSlices)
        #expect(captionSlices.allSatisfy
        {
            guard case .caption = $0.source
            else
            {
                return false
            }
            return true
        })
        for fragment in snapshot.fragments
        {
            guard case let .grid(fragment) = fragment
            else
            {
                Issue.record("Expected only grid fragments")
                continue
            }
            switch fragment.content
            {
            case .region, .captionLine, .columnTrack, .rowTrack,
                 .cell, .cellLine, .rule:
                break
            }
        }
        #expect(snapshot.fragments.map(\.anchor.fragmentOrdinal)
            == Array(snapshot.fragments.indices))
    }

    @MainActor
    @Test("regular tables carry no caption lines")
    func regularTable() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: false)
        )
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 360)
        )
        #expect(snapshot.grids.first?.captionLines == [])
        #expect(snapshot.fragments.allSatisfy
        {
            guard case let .grid(fragment) = $0
            else
            {
                return false
            }
            guard case .captionLine = fragment.content
            else
            {
                return true
            }
            return false
        })
    }
}
