import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

@Suite("Viewport requests")
struct ViewportRequestTests
{
    @MainActor
    @Test("a request preserves exact finite bounds and capacity")
    func exactRequest() throws
    {
        let layout = try ViewportFixture.layout()
        let bounds = try ViewportFixture.bounds(
            of: layout.fragments[2]
        )
        let request = try #require(ViewportRequest(
            expectedLayoutLineage: layout.lineage,
            generation: 23,
            visibleBounds: bounds,
            precedingOverscanExtent: 20,
            followingOverscanExtent: 30,
            maximumResidentCount: 9
        ))
        #expect(request.expectedLayoutLineage == layout.lineage)
        #expect(request.generation == 23)
        #expect(request.visibleBounds == bounds)
        #expect(request.precedingOverscanExtent == 20)
        #expect(request.followingOverscanExtent == 30)
        #expect(request.maximumResidentCount == 9)
    }

    @MainActor
    @Test("invalid dimensions extents and capacities are refused")
    func invalidRequest() throws
    {
        let layout = try ViewportFixture.layout()
        let origin = try #require(LayoutPoint(x: 0, y: 0))
        let zeroWidthSize = try #require(LayoutSize(
            width: 0,
            height: 10
        ))
        let zeroHeightSize = try #require(LayoutSize(
            width: 10,
            height: 0
        ))
        let zeroWidth = try #require(LayoutRectangle(
            origin: origin,
            size: zeroWidthSize
        ))
        let zeroHeight = try #require(LayoutRectangle(
            origin: origin,
            size: zeroHeightSize
        ))
        for bounds in [zeroWidth, zeroHeight]
        {
            #expect(make(layout, bounds: bounds) == nil)
        }
        let bounds = try ViewportFixture.bounds(of: layout.fragments[0])
        let invalidExtents: [Double] = [
            -1,
            .infinity,
            -.infinity,
            .nan
        ]
        for extent in invalidExtents
        {
            #expect(make(layout, bounds: bounds, preceding: extent) == nil)
            #expect(make(layout, bounds: bounds, following: extent) == nil)
        }
        #expect(make(layout, bounds: bounds, limit: 0) == nil)
        #expect(make(layout, bounds: bounds, limit: -1) == nil)
    }

    func make(
        _ layout: LayoutSnapshot,
        bounds: LayoutRectangle,
        preceding: Double = 0,
        following: Double = 0,
        limit: Int = 1
    ) -> ViewportRequest?
    {
        ViewportRequest(
            expectedLayoutLineage: layout.lineage,
            generation: 1,
            visibleBounds: bounds,
            precedingOverscanExtent: preceding,
            followingOverscanExtent: following,
            maximumResidentCount: limit
        )
    }
}
