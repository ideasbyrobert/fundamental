import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

@Suite("Viewport width admission")
struct ViewportWidthRefusalTests
{
    @MainActor
    @Test("the vertical viewport requires the exact layout width")
    func fullWidth() throws
    {
        let layout = try ViewportFixture.layout()
        let target = layout.fragments[3]
        let narrowSize = try #require(LayoutSize(
            width: layout.size.width - 1,
            height: target.frame.size.height
        ))
        let narrowBounds = try #require(LayoutRectangle(
            origin: target.frame.origin,
            size: narrowSize
        ))
        let narrowRequest = try ViewportFixture.request(
            layout: layout,
            bounds: narrowBounds
        )
        #expect(ViewportSnapshot(
            layout,
            request: narrowRequest
        ) == nil)
        let shiftedOrigin = try #require(LayoutPoint(
            x: 1,
            y: target.frame.minY
        ))
        let shiftedBounds = try #require(LayoutRectangle(
            origin: shiftedOrigin,
            size: target.frame.size
        ))
        let shiftedRequest = try ViewportFixture.request(
            layout: layout,
            bounds: shiftedBounds
        )
        #expect(ViewportSnapshot(
            layout,
            request: shiftedRequest
        ) == nil)
    }
}
