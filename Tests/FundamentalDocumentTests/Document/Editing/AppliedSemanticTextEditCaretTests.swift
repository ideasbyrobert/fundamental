import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextEditTests
{
    @Test("following affinity repairs a combining suffix seam")
    func followingAffinityRepairsCombiningSuffixSeam() throws
    {
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([SemanticRun(text: "\u{301}B")]))
        ]
        let candidate = try Self.apply(
            text: "e",
            at: 0,
            blocks: blocks
        )
        let result = try #require(candidate)

        #expect(result.caret.point.utf16Offset.value == 2)
    }

    @Test("following affinity repairs a grapheme spanning both seams")
    func followingAffinityRepairsGraphemeSpanningBothSeams() throws
    {
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([
                SemanticRun(text: "👩"),
                SemanticRun(text: "💻")
            ]))
        ]
        let candidate = try Self.apply(
            text: "\u{200D}",
            at: 2,
            blocks: blocks
        )
        let result = try #require(candidate)

        #expect(result.caret.point.utf16Offset.value == 5)
    }
}
