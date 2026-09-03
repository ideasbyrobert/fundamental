import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

@Suite("Viewport source lineage")
struct ViewportSourceTests
{
    @MainActor
    @Test("the snapshot preserves lineage extent and a visible source anchor")
    func visibleAnchor() throws
    {
        let layout = try ViewportFixture.layout()
        let target = layout.fragments[3]
        let bounds = try ViewportFixture.bounds(of: target)
        let request = try ViewportFixture.request(
            layout: layout,
            bounds: bounds,
            generation: 29
        )
        let snapshot = try #require(ViewportSnapshot(
            layout,
            request: request
        ))
        #expect(snapshot.lineage.layout == layout.lineage)
        #expect(snapshot.lineage.generation == 29)
        #expect(snapshot.lineage.specification == request.specification)
        #expect(snapshot.visibleBounds == bounds)
        #expect(snapshot.documentSize == layout.size)
        #expect(snapshot.sourceAnchor.fragment == target.anchor)
        #expect(snapshot.sourceAnchor.relativeX == 0)
        #expect(snapshot.sourceAnchor.relativeY == 0)
        #expect(snapshot.residents.first.fragment.source == target.source)
    }

    @MainActor
    @Test("an overscan-only viewport anchors an actual resident")
    func overscanAnchor() throws
    {
        let layout = try ViewportFixture.layout()
        let last = try #require(layout.fragments.last)
        let origin = try #require(LayoutPoint(
            x: 0,
            y: last.frame.maxY + 2
        ))
        let size = try #require(LayoutSize(
            width: last.frame.size.width,
            height: 2
        ))
        let bounds = try #require(LayoutRectangle(
            origin: origin,
            size: size
        ))
        let request = try ViewportFixture.request(
            layout: layout,
            bounds: bounds,
            preceding: last.frame.size.height + 4,
            limit: 2
        )
        let snapshot = try #require(ViewportSnapshot(
            layout,
            request: request
        ))
        let resident = try #require(snapshot.residents.all.first
        {
            $0.fragment.anchor == snapshot.sourceAnchor.fragment
        })
        #expect(resident.residence == .overscan(.preceding))
        #expect(snapshot.sourceAnchor.relativeY < 0)
    }
}
