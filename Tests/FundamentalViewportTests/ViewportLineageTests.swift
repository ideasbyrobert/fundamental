import Testing

@testable import FundamentalViewport

@Suite("Viewport specification lineage")
struct ViewportLineageTests
{
    @MainActor
    @Test("equal generations distinguish different residence specifications")
    func specificationIdentity() throws
    {
        let layout = try ViewportFixture.layout()
        let bounds = try ViewportFixture.bounds(
            of: layout.fragments[3]
        )
        let compact = try ViewportFixture.request(
            layout: layout,
            bounds: bounds,
            preceding: 10,
            following: 20,
            limit: 3,
            generation: 31
        )
        let expanded = try ViewportFixture.request(
            layout: layout,
            bounds: bounds,
            preceding: 30,
            following: 40,
            limit: 5,
            generation: 31
        )
        let compactSnapshot = try #require(ViewportSnapshot(
            layout,
            request: compact
        ))
        let expandedSnapshot = try #require(ViewportSnapshot(
            layout,
            request: expanded
        ))
        #expect(compactSnapshot.lineage.generation
            == expandedSnapshot.lineage.generation)
        #expect(compactSnapshot.lineage != expandedSnapshot.lineage)
        #expect(compactSnapshot.lineage.specification == compact.specification)
        #expect(expandedSnapshot.lineage.specification
            == expanded.specification)
        #expect(compact.specification.visibleBounds == bounds)
        #expect(compact.specification.precedingOverscanExtent == 10)
        #expect(compact.specification.followingOverscanExtent == 20)
        #expect(compact.specification.maximumResidentCount == 3)
    }
}
