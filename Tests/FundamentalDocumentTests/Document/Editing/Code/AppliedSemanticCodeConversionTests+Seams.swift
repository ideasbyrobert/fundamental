import Testing

@testable import FundamentalDocument

extension AppliedSemanticCodeConversionTests
{
    @Test("new code seams do not absorb a preceding carriage return")
    func carriageReturnSeams() throws
    {
        let cases: [(String, String, String)] = [
            ("A", "B", "A\nB"), ("A\r", "B", "A\r\r\nB"),
            ("A\r", "\nB", "A\r\r\n\nB"),
            ("A\r\n", "B", "A\r\n\nB"), ("A\n", "B", "A\n\nB"),
            ("", "B", "\nB"), ("A\r", "", "A\r\r\n")
        ]
        for (first, last, expected) in cases
        {
            let source = try SemanticWritingTestDocument(
                [.monostyled, .monostyled, .body],
                texts: [first, last, "After"]
            )
            let conversion = SemanticCodeConversion(
                range: try source.range((0, 0), (2, 0))
            )
            let applied = try #require(AppliedSemanticCodeConversion(
                conversion, in: source.document
            ))
            let result = try CodeConversionTestValue.applying(
                conversion, to: source.document
            )
            CodeConversionTestValue.expectText(result, [expected, "After"])
            let selection = DocumentSelection(
                range: try source.range((0, first.utf16.count), (1, 0))
            )
            let mapped = try #require(applied.selection(
                selection, from: source.document, to: result
            ))
            #expect(mapped.range.start.utf16Offset.value == first.utf16.count)
            #expect(mapped.range.end.utf16Offset.value ==
                first.utf16.count + (first.hasSuffix("\r") ? 2 : 1))
            #expect(ResolvedDocumentRange(mapped.range, in: result) != nil)
        }
    }

    @Test("empty code between blocks still contributes its own source line")
    func emptyMiddleBlock() throws
    {
        let source = try SemanticWritingTestDocument(
            [.monostyled, .monostyled, .body], texts: ["A\r", "", "B"]
        )
        let result = try CodeConversionTestValue.applying(
            SemanticCodeConversion(range: source.range((0, 0), (2, 1))),
            to: source.document
        )
        CodeConversionTestValue.expectText(result, ["A\r\r\n\nB"])
    }
}
