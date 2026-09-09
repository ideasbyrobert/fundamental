import Testing

@testable import FundamentalDocument

extension AppliedSemanticCodeConversionTests
{
    @Test("many source lines preserve content in single and fragmented runs")
    func manySourceLines() throws
    {
        let count = 16_384
        let line = "\tlet letter = \"e\u{301} 😀\""
        let whole = String(repeating: line + "\r\n", count: count)
        let cases = [
            [SemanticRun(text: whole)],
            Array(repeating: SemanticRun(text: line + "\r\n"), count: count)
        ]
        for runs in cases
        {
            let source = try SemanticWritingTestDocument(blocks: [
                CodeConversionTestValue.code(runs)
            ])
            let identities = CodeConversionTestValue.identities(count)
            let conversion = try #require(SemanticCodeConversion(
                range: source.range((0, 0), (0, 0)), proseStyle: .body,
                continuationBlockIDs: identities
            ))
            let result = try CodeConversionTestValue.applying(
                conversion, to: source.document
            )
            #expect(result.content.blocks.count == count + 1)
            #expect(result.content.blocks.dropFirst().map(\.blockID) ==
                identities)
            CodeConversionTestValue.expectText(
                result, Array(repeating: line, count: count) + [""]
            )
        }
    }
}
