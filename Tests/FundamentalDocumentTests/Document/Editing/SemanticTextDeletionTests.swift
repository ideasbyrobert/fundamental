import Testing

@testable import FundamentalDocument

extension SemanticTextEditTests
{
    @Test("forward deletion preserves its range")
    func forwardDeletionPreservesItsRange() throws
    {
        let range = try Self.range(from: 2, to: 8)
        let deletion = try #require(SemanticTextDeletion(range: range))

        #expect(deletion.range == range)
    }

    @Test("reverse deletion preserves its range direction")
    func reverseDeletionPreservesItsRangeDirection() throws
    {
        let range = try Self.range(from: 8, to: 2)
        let deletion = try #require(SemanticTextDeletion(range: range))

        #expect(deletion.range.start.utf16Offset.value == 8)
        #expect(deletion.range.end.utf16Offset.value == 2)
    }

    @Test("collapsed deletion is refused")
    func collapsedDeletionIsRefused() throws
    {
        let point = try Self.point(offset: 4)

        #expect(SemanticTextDeletion(
            range: DocumentRange.caret(at: point)
        ) == nil)
    }

    @Test("cross-block deletion is refused")
    func crossBlockDeletionIsRefused() throws
    {
        let range = try Self.range(
            from: (3, 2),
            to: (9, 8)
        )

        #expect(SemanticTextDeletion(range: range) == nil)
    }
}
