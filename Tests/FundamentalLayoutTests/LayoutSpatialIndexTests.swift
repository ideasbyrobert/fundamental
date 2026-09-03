import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("The layout spatial index")
struct LayoutSpatialIndexTests
{
    @MainActor
    @Test("a long block is line-resident and queries stop at limit plus one")
    func boundedQuery() throws
    {
        let text = String(
            repeating: "bounded native line content ",
            count: 300
        )
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct(text)
        ]))
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 120)
        )
        #expect(snapshot.fragments.count > 100)
        #expect(snapshot.fragments.allSatisfy
        {
            guard case .lines = $0
            else
            {
                return false
            }
            return true
        })
        let origin = try #require(LayoutPoint(x: 0, y: 0))
        let fullBounds = try #require(LayoutRectangle(
            origin: origin,
            size: snapshot.size
        ))
        let limited = snapshot.queryDiagnostics(
            intersecting: fullBounds,
            limit: 4
        )
        #expect(limited.query.fragments.count == 4)
        #expect(limited.query.hasMore)
        #expect(limited.examinedFragmentCount == 5)
        let last = try #require(snapshot.fragments.last)
        let tail = snapshot.queryDiagnostics(
            intersecting: last.frame,
            limit: 4
        )
        #expect(tail.query.fragments.map(\.anchor).contains(last.anchor))
        #expect(!tail.query.hasMore)
        #expect(tail.examinedFragmentCount < 4)
        #expect(tail.examinedFragmentCount < snapshot.fragments.count)
    }

    @MainActor
    @Test("directional queries return nearest ends without full traversal")
    func directionalQuery() throws
    {
        let text = String(
            repeating: "directional native line content ",
            count: 300
        )
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct(text)
        ]))
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 120)
        )
        let origin = try #require(LayoutPoint(x: 0, y: 0))
        let bounds = try #require(LayoutRectangle(
            origin: origin,
            size: snapshot.size
        ))
        let ascending = snapshot.fragments(
            intersecting: bounds,
            limit: 3,
            direction: .ascendingMinimumY
        )
        let descending = snapshot.fragments(
            intersecting: bounds,
            limit: 3,
            direction: .descendingMaximumY
        )
        #expect(ascending.fragments.map(\.anchor)
            == Array(snapshot.fragments.prefix(3)).map(\.anchor))
        #expect(descending.fragments.map(\.anchor)
            == Array(snapshot.fragments.suffix(3).reversed()).map(\.anchor))
        #expect(ascending.hasMore)
        #expect(descending.hasMore)
    }
}
