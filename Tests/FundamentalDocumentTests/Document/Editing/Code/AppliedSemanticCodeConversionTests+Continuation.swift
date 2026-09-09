import Testing

@testable import FundamentalDocument

extension AppliedSemanticCodeConversionTests
{
    @Test("native callers can allocate exact canonical continuation identities")
    func proseContinuationCountsFollowSourceLines() throws
    {
        let cases = [("", 0), ("\r", 1), ("\n", 1), ("\r\n", 1),
                     ("A\r\n\rB\n", 3), ("😀e\u{301}\r\nЯ\n", 2)]
        for language: String? in [nil, " Swift "]
        {
            for (text, expected) in cases
            {
                let source = try SemanticWritingTestDocument(blocks: [
                    CodeConversionTestValue.code(
                        [SemanticRun(text: text)], language: language
                    )
                ])
                let range = try source.range((0, 0), (0, 0))
                let count = try #require(
                    SemanticCodeConversion.proseContinuationCount(
                        in: range, of: source.document
                    )
                )
                #expect(count == expected)
                let identities = CodeConversionTestValue.identities(count)
                let conversion = try #require(SemanticCodeConversion(
                    range: range, proseStyle: .body,
                    continuationBlockIDs: identities
                ))
                let result = try CodeConversionTestValue.applying(
                    conversion, to: source.document
                )
                #expect(result.content.blocks.count == expected + 1)
                #expect(result.content.blocks.map(\.blockID) ==
                    [source.document.content.blocks[0].blockID] + identities)
            }
        }
    }

    @Test("continuation counts respect whole-block selection and split runs")
    func proseContinuationCountsRespectSelection() throws
    {
        let code = try CodeConversionTestValue.code([
            SemanticRun(text: "A\r"), SemanticRun(text: "\nB")
        ])
        let source = try SemanticWritingTestDocument(blocks: [
            code, CanonicalBlockStyle.body.semanticBlock(
                runs: [SemanticRun(text: "C")]
            ), CodeConversionTestValue.code([SemanticRun(text: "X\rY\n")])
        ])
        for (start, end, expected) in [
            ((0, 0), (2, 0), 1), ((2, 0), (0, 0), 1),
            ((0, 0), (2, 4), 3), ((2, 0), (2, 0), 2),
            ((1, 0), (1, 0), 0)
        ]
        {
            #expect(try SemanticCodeConversion.proseContinuationCount(
                in: source.range(start, end), of: source.document
            ) == expected)
        }
    }
}
