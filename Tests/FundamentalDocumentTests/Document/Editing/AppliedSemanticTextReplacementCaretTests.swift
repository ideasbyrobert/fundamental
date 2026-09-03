import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextReplacementTests
{
    @Test("scalar-interior replacement bounds remain admitted")
    func scalarInteriorReplacementBoundsRemainAdmitted() throws
    {
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([SemanticRun(text: "e\u{301}X")]))
        ]
        let candidate = try Self.apply(
            text: "!",
            start: 1,
            end: 2,
            blocks: blocks
        )
        let result = try #require(candidate)

        #expect(try Self.text(in: result) == "e!X")
        #expect(result.caret.point.utf16Offset.value == 2)
    }

    @Test("following affinity repairs a combining suffix seam")
    func followingAffinityRepairsCombiningSuffixSeam() throws
    {
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([
                SemanticRun(text: "X"),
                SemanticRun(text: "\u{301}B")
            ]))
        ]
        let candidate = try Self.apply(
            text: "e",
            start: 0,
            end: 1,
            blocks: blocks
        )
        let result = try #require(candidate)

        #expect(result.caret.point.utf16Offset.value == 2)
    }

    @Test("following affinity repairs a grapheme spanning both seams")
    func followingAffinityRepairsBothSeams() throws
    {
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([
                SemanticRun(text: "👩"),
                SemanticRun(text: "X"),
                SemanticRun(text: "💻")
            ]))
        ]
        let candidate = try Self.apply(
            text: "\u{200D}",
            start: 2,
            end: 3,
            blocks: blocks
        )
        let result = try #require(candidate)

        #expect(result.caret.point.utf16Offset.value == 5)
    }
}
