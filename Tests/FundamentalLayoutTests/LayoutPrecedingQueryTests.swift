import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Preceding layout queries")
struct LayoutPrecedingQueryTests
{
    @MainActor
    @Test("heterogeneous grid heights rank greatest maximum Y first")
    func heterogeneousGrid() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: true)
        )
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 360)
        )
        let grid = try #require(snapshot.grids.first)
        let origin = try #require(LayoutPoint(
            x: 0,
            y: grid.frame.minY
        ))
        let size = try #require(LayoutSize(
            width: grid.frame.size.width,
            height: grid.frame.size.height - 1
        ))
        let bounds = try #require(LayoutRectangle(
            origin: origin,
            size: size
        ))
        let candidates = snapshot.fragments.filter
        {
            $0.frame.intersects(bounds)
        }
        let expected = candidates.sorted
        {
            if $0.frame.maxY != $1.frame.maxY
            {
                return $0.frame.maxY > $1.frame.maxY
            }
            return $0.anchor.fragmentOrdinal
                < $1.anchor.fragmentOrdinal
        }
        let diagnostics = snapshot.queryDiagnostics(
            intersecting: bounds,
            limit: 3,
            direction: .descendingMaximumY
        )
        let query = diagnostics.query
        #expect(query.fragments.map(\.anchor)
            == Array(expected.prefix(3)).map(\.anchor))
        let reversedMinimumY = candidates.sorted
        {
            $0.frame.minY > $1.frame.minY
        }
        #expect(query.fragments.map(\.anchor)
            != Array(reversedMinimumY.prefix(3)).map(\.anchor))
        #expect(query.hasMore)
        #expect(diagnostics.examinedFragmentCount == 4)
    }

    @MainActor
    @Test("zero-area bounds examine no fragments")
    func zeroArea() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct(String(repeating: "line ", count: 300))
        ]))
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 120)
        )
        let origin = try #require(LayoutPoint(x: 0, y: 20))
        let zeroHeight = try #require(LayoutSize(
            width: snapshot.size.width,
            height: 0
        ))
        let bounds = try #require(LayoutRectangle(
            origin: origin,
            size: zeroHeight
        ))
        let diagnostics = snapshot.queryDiagnostics(
            intersecting: bounds,
            limit: 3,
            direction: .descendingMaximumY
        )
        #expect(diagnostics.query.fragments.isEmpty)
        #expect(!diagnostics.query.hasMore)
        #expect(diagnostics.examinedFragmentCount == 0)
    }
}
