import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

@Suite("Viewport table paint order")
struct ViewportTableOrderTests
{
    @MainActor
    @Test("resident table fragments retain exact upstream paint order")
    func exactOrder() throws
    {
        let layout = try ViewportFixture.tableLayout()
        let origin = try #require(LayoutPoint(x: 0, y: 0))
        let bounds = try #require(LayoutRectangle(
            origin: origin,
            size: layout.size
        ))
        let request = try ViewportFixture.request(
            layout: layout,
            bounds: bounds,
            limit: layout.fragments.count
        )
        let snapshot = try #require(ViewportSnapshot(
            layout,
            request: request
        ))
        let expected = layout.fragments.map(\.anchor)
        let actual = snapshot.residents.all.map(\.fragment.anchor)
        #expect(actual == expected)
        #expect(actual.map(\.fragmentOrdinal)
            == Array(layout.fragments.indices))
        let geometryOrder = layout.fragments.sorted
        {
            if $0.frame.minY != $1.frame.minY
            {
                return $0.frame.minY < $1.frame.minY
            }
            return $0.frame.minX < $1.frame.minX
        }.map(\.anchor)
        #expect(geometryOrder != expected)
    }
}
