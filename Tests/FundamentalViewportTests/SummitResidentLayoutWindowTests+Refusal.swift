import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

extension SummitResidentLayoutWindowTests
{
    @Test("overflow empty and foreign windows refuse before publication")
    func windowRefusal() throws
    {
        let blocks = ViewportWindowFixture.fixedBlocks(
            count: 3,
            prefix: "refusal"
        )
        let projection = try ViewportWindowFixture.projection(blocks)
        let layouts = try ViewportWindowFixture.layouts(
            projection: projection,
            width: 360
        )
        let fragments = layouts.eager.fragments
        let overflowBounds = try ViewportWindowFixture.bounds(
            width: 360,
            originY: fragments[0].frame.minY,
            height: fragments[1].frame.maxY
                - fragments[0].frame.minY
        )
        let overflow = try request(
            layouts.indexed,
            bounds: overflowBounds,
            limit: 1
        )
        #expect(layouts.indexed.queryDiagnostics(
            intersecting: overflowBounds,
            limit: 1
        ).query.hasMore)
        #expect(ViewportResidentExtentWindow.admit(
            indexed: layouts.indexed,
            request: overflow
        ) == nil)
        let gapOrigin = fragments[0].frame.maxY
        let gapHeight = fragments[1].frame.minY - gapOrigin
        let gap = try request(
            layouts.indexed,
            bounds: ViewportWindowFixture.bounds(
                width: 360,
                originY: gapOrigin,
                height: gapHeight
            ),
            limit: 2
        )
        #expect(layouts.indexed.queryDiagnostics(
            intersecting: gap.visibleBounds,
            limit: 2
        ).query.extents.isEmpty)
        #expect(ViewportResidentExtentWindow.admit(
            indexed: layouts.indexed,
            request: gap
        ) == nil)
        let foreign = try ViewportWindowFixture.layouts(
            projection: ViewportWindowFixture.projection(
                blocks,
                generation: 10
            ),
            width: 360
        ).indexed
        let local = try request(
            layouts.indexed,
            bounds: try ViewportWindowFixture.bounds(
                width: 360,
                originY: fragments[0].frame.minY,
                height: fragments[0].frame.size.height
            ),
            limit: 8
        )
        #expect(ViewportResidentExtentWindow.admit(
            indexed: layouts.indexed,
            request: local
        ) != nil)
        #expect(ViewportResidentExtentWindow.admit(
            indexed: foreign,
            request: local
        ) == nil)
        try expectTableRuleCannotAnchor()
    }

}
