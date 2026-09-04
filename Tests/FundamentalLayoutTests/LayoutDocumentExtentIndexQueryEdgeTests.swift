import Testing

@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    @Test("limits and diagnostics equal eager interval queries")
    func queryLimitAndDiagnostics() throws
    {
        let result = try longProduct()
        let bounds = try fullBounds(result.index)
        let actual = result.index.queryDiagnostics(
            intersecting: bounds,
            limit: 4
        )
        let expected = result.snapshot.queryDiagnostics(
            intersecting: bounds,
            limit: 4
        )
        expectQueryParity(actual.query, expected.query)
        #expect(actual.examinedExtentCount
            == expected.examinedFragmentCount)
        #expect(actual.examinedExtentCount == 5)
        let complete = result.index.queryDiagnostics(
            intersecting: bounds,
            limit: result.index.extents.count
        )
        #expect(complete.query.extents.count
            == result.index.extents.count)
        #expect(!complete.query.hasMore)
    }

    @MainActor
    @Test("zero-area and outside queries publish exact absence")
    func absentQuery() throws
    {
        let result = try longProduct()
        let zeroOrigin = try #require(LayoutPoint(x: 0, y: 20))
        let zeroSize = try #require(LayoutSize(
            width: result.index.size.width,
            height: 0
        ))
        let zero = try #require(LayoutRectangle(
            origin: zeroOrigin,
            size: zeroSize
        ))
        let outsideOrigin = try #require(LayoutPoint(
            x: 0,
            y: result.index.size.height + 1
        ))
        let outsideSize = try #require(LayoutSize(
            width: result.index.size.width,
            height: 10
        ))
        let outside = try #require(LayoutRectangle(
            origin: outsideOrigin,
            size: outsideSize
        ))
        for bounds in [zero, outside]
        {
            let diagnostics = result.index.queryDiagnostics(
                intersecting: bounds,
                limit: 3
            )
            #expect(diagnostics.query.extents.isEmpty)
            #expect(!diagnostics.query.hasMore)
            #expect(diagnostics.examinedExtentCount == 0)
        }
    }
}
