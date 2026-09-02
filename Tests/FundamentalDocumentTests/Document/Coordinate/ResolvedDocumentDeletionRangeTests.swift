import Testing

@testable import FundamentalDocument

@Suite("A resolved document deletion range")
struct ResolvedDocumentDeletionRangeTests
{
    @Test("a forward range preserves direction and ordered bounds")
    func forwardRangePreservesDirectionAndBounds() throws
    {
        let range = try Self.range(start: 1, end: 3)
        let deletion = try #require(ResolvedDocumentDeletionRange(
            range,
            in: Self.document()
        ))
        let lower = try Self.offset(1)
        let upper = try Self.offset(3)

        #expect(deletion.range == range)
        #expect(deletion.blockIndex == 0)
        #expect(deletion.lowerUTF16Offset == lower)
        #expect(deletion.upperUTF16Offset == upper)
    }

    @Test("a reverse range preserves direction and orders bounds")
    func reverseRangePreservesDirectionAndOrdersBounds() throws
    {
        let range = try Self.range(start: 3, end: 1)
        let deletion = try #require(ResolvedDocumentDeletionRange(
            range,
            in: Self.document()
        ))
        let lower = try Self.offset(1)
        let upper = try Self.offset(3)

        #expect(deletion.range == range)
        #expect(deletion.range.start.utf16Offset == upper)
        #expect(deletion.lowerUTF16Offset == lower)
        #expect(deletion.upperUTF16Offset == upper)
    }

    private static func offset(
        _ value: Int
    ) throws -> DocumentUTF16Offset
    {
        try #require(DocumentUTF16Offset(value))
    }
}
