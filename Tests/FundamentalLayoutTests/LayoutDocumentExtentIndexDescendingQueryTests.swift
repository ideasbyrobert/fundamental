import Testing

@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    @Test("descending queries order maximum y then paint order")
    func descendingQuery() throws
    {
        let result = try longProduct()
        let bounds = try fullBounds(result.index)
        let actual = result.index.extents(
            intersecting: bounds,
            limit: 5,
            direction: .descendingMaximumY
        )
        let expected = result.snapshot.fragments(
            intersecting: bounds,
            limit: 5,
            direction: .descendingMaximumY
        )
        expectQueryParity(actual, expected)
        #expect(actual.extents.map(\.anchor)
            == Array(result.index.extents.suffix(5).reversed())
                .map(\.anchor))
        let tail = result.index.extents.count - 3
        let tailFrame = result.index.extents[tail].frame
        let tailOrigin = tailFrame.minY + tailFrame.size.height / 2
        let interior = try interiorBounds(
            result.index,
            extentOrdinal: tail,
            height: result.index.size.height - tailOrigin
        )
        let interiorActual = result.index.extents(
            intersecting: interior,
            limit: 2,
            direction: .descendingMaximumY
        )
        let interiorExpected = result.snapshot.fragments(
            intersecting: interior,
            limit: 2,
            direction: .descendingMaximumY
        )
        expectQueryParity(interiorActual, interiorExpected)
        #expect(interiorActual.extents.first?.anchor
            == result.index.extents.last?.anchor)
    }
}
