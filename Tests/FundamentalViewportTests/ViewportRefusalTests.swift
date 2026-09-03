import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

@Suite("Viewport refusal")
struct ViewportRefusalTests
{
    @MainActor
    @Test("stale layout lineage is refused atomically")
    func staleLineage() throws
    {
        let expected = try ViewportFixture.layout(generation: 10)
        let actual = try ViewportFixture.layout(generation: 11)
        let bounds = try ViewportFixture.bounds(
            of: expected.fragments[2]
        )
        let request = try ViewportFixture.request(
            layout: expected,
            bounds: bounds
        )
        #expect(ViewportSnapshot(actual, request: request) == nil)
    }

    @MainActor
    @Test("visible residents are never evicted for overscan")
    func visibleCapacity() throws
    {
        let layout = try ViewportFixture.layout()
        let first = layout.fragments[3]
        let second = layout.fragments[4]
        let origin = first.frame.origin
        let size = try #require(LayoutSize(
            width: first.frame.size.width,
            height: second.frame.maxY - first.frame.minY
        ))
        let bounds = try #require(LayoutRectangle(
            origin: origin,
            size: size
        ))
        let request = try ViewportFixture.request(
            layout: layout,
            bounds: bounds,
            preceding: 100,
            following: 100,
            limit: 2
        )
        let snapshot = try #require(ViewportSnapshot(
            layout,
            request: request
        ))
        #expect(snapshot.residents.all.count == 2)
        #expect(snapshot.residents.all.allSatisfy
        {
            $0.residence == .visible
        })
    }

    @MainActor
    @Test("excess visible work and empty residence are refused")
    func capacityAndAbsence() throws
    {
        let layout = try ViewportFixture.layout()
        let first = layout.fragments[3]
        let second = layout.fragments[4]
        let size = try #require(LayoutSize(
            width: first.frame.size.width,
            height: second.frame.maxY - first.frame.minY
        ))
        let crowded = try #require(LayoutRectangle(
            origin: first.frame.origin,
            size: size
        ))
        let smallRequest = try ViewportFixture.request(
            layout: layout,
            bounds: crowded,
            limit: 1
        )
        #expect(ViewportSnapshot(layout, request: smallRequest) == nil)
        let origin = try #require(LayoutPoint(
            x: 0,
            y: layout.size.height + 100
        ))
        let emptyBounds = try #require(LayoutRectangle(
            origin: origin,
            size: first.frame.size
        ))
        let emptyRequest = try ViewportFixture.request(
            layout: layout,
            bounds: emptyBounds
        )
        #expect(ViewportSnapshot(layout, request: emptyRequest) == nil)
    }
}
