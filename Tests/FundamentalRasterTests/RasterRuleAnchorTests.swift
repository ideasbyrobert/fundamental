import Testing

@testable import FundamentalLayout
@testable import FundamentalRaster

@Suite("Raster rule anchor ownership")
struct RasterRuleAnchorTests
{
    @MainActor
    @Test("a rule never becomes the published viewport source anchor")
    func sourceAnchor() throws
    {
        let layout = try RasterFixture.layout([
            RasterFixture.table()
        ], width: 360)
        let viewport = try RasterFixture.viewport(layout)
        let source = try #require(layout.fragments.first
        {
            $0.anchor == viewport.sourceAnchor.fragment
        })
        if case let .grid(fragment) = source,
           case .rule = fragment.content
        {
            Issue.record("A rule cannot own source-anchor geometry")
        }
        let raster = try RasterFixture.snapshot(viewport)
        let region = try #require(raster.interactionMap.regions.first
        {
            $0.residentID == raster.sourceAnchor.residentID
        })
        #expect(raster.sourceAnchor.relativeX
            == region.frame.minX - viewport.visibleBounds.minX)
        #expect(raster.sourceAnchor.relativeY
            == region.frame.minY - viewport.visibleBounds.minY)
    }
}
