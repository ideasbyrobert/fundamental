import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

extension RasterFixture
{
    static func viewport(
        _ layout: LayoutSnapshot,
        y: Double = 0,
        height: Double? = nil,
        preceding: Double = 0,
        following: Double = 0,
        limit: Int? = nil,
        generation: UInt64 = 13
    ) throws -> ViewportSnapshot
    {
        let origin = try #require(LayoutPoint(x: 0, y: y))
        let size = try #require(LayoutSize(
            width: layout.size.width,
            height: height ?? layout.size.height
        ))
        let bounds = try #require(LayoutRectangle(
            origin: origin,
            size: size
        ))
        let request = try #require(ViewportRequest(
            expectedLayoutLineage: layout.lineage,
            generation: generation,
            visibleBounds: bounds,
            precedingOverscanExtent: preceding,
            followingOverscanExtent: following,
            maximumResidentCount: limit ?? layout.fragments.count
        ))
        return try #require(ViewportSnapshot(layout, request: request))
    }
}
