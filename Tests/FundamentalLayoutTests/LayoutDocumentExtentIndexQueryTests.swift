import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    @Test("ascending queries equal eager lightweight intersections")
    func ascendingQuery() throws
    {
        let result = try longProduct()
        let bounds = try fullBounds(result.index)
        let actual = result.index.extents(
            intersecting: bounds,
            limit: 4
        )
        let expected = result.snapshot.fragments(
            intersecting: bounds,
            limit: 4
        )
        expectQueryParity(actual, expected)
        #expect(actual.extents.count == 4)
        #expect(actual.hasMore)
        let middle = result.index.extents.count / 2
        let lineHeight = result.index.extents[middle].frame.size.height
        let interior = try interiorBounds(
            result.index,
            extentOrdinal: middle,
            height: lineHeight * 4
        )
        let interiorActual = result.index.extents(
            intersecting: interior,
            limit: 4
        )
        let interiorExpected = result.snapshot.fragments(
            intersecting: interior,
            limit: 4
        )
        expectQueryParity(interiorActual, interiorExpected)
        #expect(interiorActual.extents.first?.anchor
            == result.index.extents[middle].anchor)
    }

    @MainActor
    @Test("overlapping table extents preserve eager paint order")
    func overlapQuery() throws
    {
        let result = try product([
            .table(try LayoutFixture.table(captioned: true))
        ], width: 360)
        let grid = try #require(result.snapshot.grids.first)
        let actual = result.index.extents(
            intersecting: grid.frame,
            limit: 10_000
        )
        let expected = result.snapshot.fragments(
            intersecting: grid.frame,
            limit: 10_000
        )
        expectQueryParity(actual, expected)
        #expect(actual.extents.count > 10)
        #expect(!actual.hasMore)
    }
}
