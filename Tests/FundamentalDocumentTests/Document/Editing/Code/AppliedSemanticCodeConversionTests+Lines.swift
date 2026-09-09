import Testing

@testable import FundamentalDocument

extension AppliedSemanticCodeConversionTests
{
    @Test("leaving code preserves blank terminal and Unicode source lines")
    func sourceLines() throws
    {
        let cases: [(String, [String])] = [
            ("", [""]), ("A", ["A"]), ("\n", ["", ""]),
            ("\r\n", ["", ""]), ("\r", ["", ""]),
            ("A\n\nB\n", ["A", "", "B", ""]),
            ("A\r\n\rB\r", ["A", "", "B", ""]),
            ("e\u{301}\r\n\t😀\rՀայերեն\n", ["e\u{301}", "\t😀", "Հայերեն", ""])
        ]
        for style in CanonicalBlockStyle.allCases where style != .monostyled
        {
            for (text, expected) in cases
            {
                let source = try SemanticWritingTestDocument(
                    [.monostyled], texts: [text]
                )
                let identities = CodeConversionTestValue.identities(
                    expected.count - 1
                )
                let conversion = try #require(SemanticCodeConversion(
                    range: source.range((0, 0), (0, 0)),
                    proseStyle: style, continuationBlockIDs: identities
                ))
                let result = try CodeConversionTestValue.applying(
                    conversion, to: source.document
                )
                CodeConversionTestValue.expectText(result, expected)
                #expect(result.content.blocks.map(\.blockID) ==
                    [source.document.content.blocks[0].blockID] + identities)
                #expect(result.content.blocks.allSatisfy
                    { CanonicalBlockStyle($0.block) == style })
            }
        }
    }

    @Test("already-prose blocks retain runs while selected code splits")
    func mixedProseConversion() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .monostyled, .numbered, .body],
            texts: ["Before", "A\r\nB", "C", "After"]
        )
        let identity = CodeConversionTestValue.identities(1)
        let result = try CodeConversionTestValue.applying(
            #require(SemanticCodeConversion(
                range: source.range((1, 1), (3, 0)),
                proseStyle: .title, continuationBlockIDs: identity
            )),
            to: source.document
        )
        CodeConversionTestValue.expectText(
            result, ["Before", "A", "B", "C", "After"]
        )
        let old = source.document.content.blocks
        #expect(result.content.blocks.map(\.blockID) ==
            [old[0].blockID, old[1].blockID, identity[0],
             old[2].blockID, old[3].blockID])
        #expect(result.content.blocks.first == old.first)
        #expect(result.content.blocks.last == old.last)
        #expect(try CodeConversionTestValue.runs(result.content.blocks[3]) ==
            CodeConversionTestValue.runs(old[2]))
    }
}
