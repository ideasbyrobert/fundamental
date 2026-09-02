import Testing

@testable import FundamentalDocument

@Suite("Resolved document ranges")
struct ResolvedDocumentRangeTests
{
    @Test("a forward same-block range preserves direction and order")
    func forwardSameBlockRangePreservesDirection() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph("ABCD"))
        ])
        let range = try Self.range(
            Self.point(offset: 1),
            Self.point(offset: 3)
        )
        let resolved = try #require(
            ResolvedDocumentRange(range, in: document)
        )

        #expect(resolved.range == range)
        #expect(resolved.start.point == range.start)
        #expect(resolved.end.point == range.end)
        #expect(resolved.lowerBound == resolved.start)
        #expect(resolved.upperBound == resolved.end)
    }

    @Test("a reverse same-block range preserves direction and orders bounds")
    func reverseSameBlockRangePreservesDirection() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph("ABCD"))
        ])
        let range = try Self.range(
            Self.point(offset: 3),
            Self.point(offset: 1)
        )
        let resolved = try #require(
            ResolvedDocumentRange(range, in: document)
        )

        #expect(resolved.start.point == range.start)
        #expect(resolved.end.point == range.end)
        #expect(resolved.lowerBound == resolved.end)
        #expect(resolved.upperBound == resolved.start)
    }

    @Test("a forward cross-block range follows canonical block order")
    func forwardCrossBlockRangeFollowsCanonicalOrder() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph("First")),
            (7, Self.paragraph("Later"))
        ])
        let range = try Self.range(
            Self.point(blockMarker: 2, offset: 5),
            Self.point(blockMarker: 7, offset: 1)
        )
        let resolved = try #require(
            ResolvedDocumentRange(range, in: document)
        )

        #expect(resolved.start.blockIndex == 0)
        #expect(resolved.end.blockIndex == 1)
        #expect(resolved.lowerBound == resolved.start)
        #expect(resolved.upperBound == resolved.end)
    }

    @Test("a reverse cross-block range keeps direction and ordered bounds")
    func reverseCrossBlockRangeKeepsDirection() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph("First")),
            (7, Self.paragraph("Later"))
        ])
        let range = try Self.range(
            Self.point(blockMarker: 7, offset: 1),
            Self.point(blockMarker: 2, offset: 5)
        )
        let resolved = try #require(
            ResolvedDocumentRange(range, in: document)
        )

        #expect(resolved.start.blockIndex == 1)
        #expect(resolved.end.blockIndex == 0)
        #expect(resolved.lowerBound == resolved.end)
        #expect(resolved.upperBound == resolved.start)
    }
}
