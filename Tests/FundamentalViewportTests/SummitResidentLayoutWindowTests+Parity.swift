import Testing

@testable import FundamentalProjection
@testable import FundamentalViewport

extension SummitResidentLayoutWindowTests
{
    @Test("top residence and two-sided overscan equal eager truth")
    func topTwoSidedParity() throws
    {
        let projection = try #require(SummitProjectionCorpus()).snapshot
        let value = try ViewportWindowFixture.product(
            projection: projection,
            width: 720,
            originY: 260,
            height: 120,
            overscan: 180,
            limit: 192
        )
        ViewportWindowFixture.expectExact(value)
        let positions = value.diagnostics.snapshot.residents.all.map
        {
            $0.residence
        }
        #expect(positions.contains(.overscan(.preceding)))
        #expect(positions.contains(.overscan(.following)))
    }

    @Test("middle and bottom residence equal eager truth")
    func middleAndBottomParity() throws
    {
        let projection = try #require(SummitProjectionCorpus()).snapshot
        let first = try ViewportWindowFixture.product(
            projection: projection,
            width: 720,
            originY: 0,
            height: 180,
            overscan: 120,
            limit: 192
        )
        let height = first.eager.size.height
        for origin in [height / 2, max(0, height - 180)]
        {
            let value = try ViewportWindowFixture.product(
                projection: projection,
                width: 720,
                originY: origin,
                height: 180,
                overscan: 120,
                limit: 192
            )
            ViewportWindowFixture.expectExact(value)
        }
    }

    @Test("distance ties visible priority anchor and paint order agree")
    func policyParity() throws
    {
        let blocks = ViewportWindowFixture.fixedBlocks(
            count: 3,
            prefix: "policy"
        )
        let projection = try ViewportWindowFixture.projection(blocks)
        let layout = try ViewportWindowFixture.layouts(
            projection: projection,
            width: 360
        ).eager
        let fragments = layout.fragments
        let lower = fragments[0].frame.maxY
        let upper = fragments[1].frame.minY
        let middle = lower + (upper - lower) / 2
        let tied = try ViewportWindowFixture.product(
            projection: projection,
            width: 360,
            originY: middle - 1,
            height: 2,
            overscan: upper - lower,
            limit: 2
        )
        ViewportWindowFixture.expectExact(tied)
        #expect(tied.expected.sourceAnchor.fragment.blockOrdinal == 0)
        let visible = try ViewportWindowFixture.product(
            projection: projection,
            width: 360,
            originY: fragments[1].frame.minY,
            height: fragments[1].frame.size.height,
            overscan: 100,
            limit: 1
        )
        ViewportWindowFixture.expectExact(visible)
        #expect(visible.expected.residents.first.residence == .visible)
    }
}
