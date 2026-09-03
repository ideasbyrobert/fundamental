import Testing

@testable import FundamentalDocument

extension SemanticTextEditTests
{
    @Test("forward replacement preserves all required facts")
    func forwardReplacementPreservesRequiredFacts() throws
    {
        let range = try Self.range(from: 1, to: 6)
        let insertion = try Self.insertion("New")
        let replacement = try #require(SemanticTextReplacement(
            range: range,
            insertion: insertion
        ))

        #expect(replacement.range == range)
        #expect(replacement.insertion == insertion)
    }

    @Test("reverse replacement preserves its range direction")
    func reverseReplacementPreservesItsRangeDirection() throws
    {
        let range = try Self.range(from: 6, to: 1)
        let replacement = try #require(SemanticTextReplacement(
            range: range,
            insertion: Self.insertion("New")
        ))

        #expect(replacement.range.start.utf16Offset.value == 6)
        #expect(replacement.range.end.utf16Offset.value == 1)
    }

    @Test("collapsed replacement is refused")
    func collapsedReplacementIsRefused() throws
    {
        let point = try Self.point(offset: 4)
        let insertion = try Self.insertion("New")

        #expect(SemanticTextReplacement(
            range: DocumentRange.caret(at: point),
            insertion: insertion
        ) == nil)
    }

    @Test("cross-block replacement is refused")
    func crossBlockReplacementIsRefused() throws
    {
        let range = try Self.range(
            from: (3, 2),
            to: (9, 8)
        )
        let insertion = try Self.insertion("New")

        #expect(SemanticTextReplacement(
            range: range,
            insertion: insertion
        ) == nil)
    }
}
