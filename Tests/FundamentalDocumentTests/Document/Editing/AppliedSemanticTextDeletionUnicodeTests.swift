import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextDeletionTests
{
    @Test("native scalar deletion exemplars retain exact spelling")
    func nativeScalarDeletionExemplarsRetainSpelling() throws
    {
        let examples: [(String, Int, Int, String)] = [
            ("e\u{301}", 1, 2, "e"),
            ("कि", 1, 2, "क"),
            ("\u{2708}\u{FE0F}", 1, 2, "\u{2708}"),
            ("🇦🇲", 2, 4, "🇦"),
            ("👍🏽", 2, 4, "👍")
        ]
        for example in examples
        {
            let blocks: [(UInt8, SemanticBlock)] = [
                (2, Self.paragraph([SemanticRun(text: example.0)]))
            ]
            let candidate = try Self.apply(
                start: example.1,
                end: example.2,
                blocks: blocks
            )
            let result = try #require(candidate)
            let actual = try Self.text(in: result)

            #expect(actual.unicodeScalars.map(\.value) ==
                example.3.unicodeScalars.map(\.value))
        }
    }

    @Test("cross-run grapheme deletion uses complete spelling")
    func crossRunGraphemeDeletionUsesCompleteSpelling() throws
    {
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([
                SemanticRun(text: "e"),
                SemanticRun(text: "\u{301}"),
                SemanticRun(text: "X")
            ]))
        ]
        let candidate = try Self.apply(
            start: 1,
            end: 2,
            blocks: blocks
        )
        let result = try #require(candidate)

        #expect(try Self.runs(in: result).map(\.text) == ["e", "X"])
    }

    @Test("three indicators place the caret before a recomposed flag")
    func threeIndicatorsPlaceCaretBeforeRecomposedFlag() throws
    {
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([
                SemanticRun(text: "\u{1F1E6}"),
                SemanticRun(text: "\u{1F1F2}"),
                SemanticRun(text: "\u{1F1FA}")
            ]))
        ]
        let candidate = try Self.apply(
            start: 2,
            end: 4,
            blocks: blocks
        )
        let result = try #require(candidate)
        let runs = try Self.runs(in: result)

        #expect(runs.map(\.text) == ["\u{1F1E6}", "\u{1F1FA}"])
        #expect(runs.flatMap(\.text.unicodeScalars).map(\.value) == [
            0x1F1E6, 0x1F1FA
        ])
        #expect(result.caret.point.utf16Offset.value == 0)
    }

    @Test("an exact Character lower bound remains exact")
    func exactCharacterLowerBoundRemainsExact() throws
    {
        let candidate = try Self.apply(start: 1, end: 3)
        let result = try #require(candidate)

        #expect(result.caret.point.utf16Offset.value == 1)
    }
}
