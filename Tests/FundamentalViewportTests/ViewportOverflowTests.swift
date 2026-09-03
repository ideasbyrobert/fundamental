import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

@Suite("Viewport geometry overflow")
struct ViewportOverflowTests
{
    @MainActor
    @Test("overscan arithmetic must remain finite")
    func finiteBands() throws
    {
        let layout = try ViewportFixture.layout()
        let size = try #require(LayoutSize(width: 1, height: 1))
        let lowOrigin = try #require(LayoutPoint(
            x: 0,
            y: -Double.greatestFiniteMagnitude
        ))
        let lowBounds = try #require(LayoutRectangle(
            origin: lowOrigin,
            size: size
        ))
        #expect(ViewportRequest(
            expectedLayoutLineage: layout.lineage,
            generation: 1,
            visibleBounds: lowBounds,
            precedingOverscanExtent: Double.greatestFiniteMagnitude,
            followingOverscanExtent: 0,
            maximumResidentCount: 1
        ) == nil)
        let highOrigin = try #require(LayoutPoint(
            x: 0,
            y: Double.greatestFiniteMagnitude - 1
        ))
        let highBounds = try #require(LayoutRectangle(
            origin: highOrigin,
            size: size
        ))
        #expect(ViewportRequest(
            expectedLayoutLineage: layout.lineage,
            generation: 1,
            visibleBounds: highBounds,
            precedingOverscanExtent: 0,
            followingOverscanExtent: Double.greatestFiniteMagnitude,
            maximumResidentCount: 1
        ) == nil)
    }
}
