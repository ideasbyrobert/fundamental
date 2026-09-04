import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

extension SummitResidentLayoutWindowTests
{
    func request(
        _ indexed: LayoutIndexedProjection,
        bounds: LayoutRectangle,
        limit: Int
    ) throws -> ViewportRequest
    {
        try #require(ViewportRequest(
            expectedLayoutLineage: indexed.lineage,
            generation: 13,
            visibleBounds: bounds,
            precedingOverscanExtent: 0,
            followingOverscanExtent: 0,
            maximumResidentCount: limit
        ))
    }

    func expectTableRuleCannotAnchor() throws
    {
        let projection = try ViewportWindowFixture.projection(
            ViewportWindowFixture.tableBlocks()
        )
        let indexed = try ViewportWindowFixture.layouts(
            projection: projection,
            width: 420
        ).indexed
        let rule = try #require(indexed.index.extents.first
        {
            $0.content == .tableRule
        })
        #expect(!rule.canAnchor)
    }
}
