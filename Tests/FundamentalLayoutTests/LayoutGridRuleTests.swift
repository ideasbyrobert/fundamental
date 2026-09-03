import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Native grid rule segments")
struct LayoutGridRuleTests
{
    @MainActor
    @Test("owners are exact and spans suppress crossing segments")
    func ownersAndSpans() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: true)
        )
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 360)
        )
        let grid = try #require(snapshot.grids.first)
        let rules: [(LayoutRectangle, LayoutGridRuleOwner)]
        rules = snapshot.fragments.compactMap
        {
            guard case let .grid(fragment) = $0,
                  case let .rule(owner) = fragment.content
            else
            {
                return nil
            }
            return (fragment.frame, owner)
        }
        #expect(!rules.isEmpty)
        for (_, owner) in rules
        {
            switch owner
            {
            case .table:
                break
            case let .row(index):
                #expect(grid.rowTracks.contains { $0.index == index })
            case let .column(index):
                #expect(grid.columnTracks.contains { $0.index == index })
            }
        }
        let wide = try #require(grid.cells.first
        {
            $0.columnSpan == 2
        })
        #expect(rules.allSatisfy
        {
            guard $0.1 == .column(wide.columnTrack + 1)
            else
            {
                return true
            }
            return !$0.0.intersects(wide.frame)
        })
        let tall = try #require(grid.cells.first
        {
            $0.rowSpan == 2
        })
        #expect(rules.allSatisfy
        {
            guard $0.1 == .row(tall.rowTrack + 1)
            else
            {
                return true
            }
            return !$0.0.intersects(tall.frame)
        })
    }
}
