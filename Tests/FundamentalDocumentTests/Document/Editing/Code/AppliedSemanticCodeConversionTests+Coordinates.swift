import Testing

@testable import FundamentalDocument

extension AppliedSemanticCodeConversionTests
{
    @Test("joining maps every valid endpoint while keeping source direction")
    func joinedCoordinates() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .monostyled, .monostyled, .monostyled, .body],
            texts: ["Before", "e\u{301}", "😀\r", "\nB", "After"]
        )
        let conversion = SemanticCodeConversion(
            range: try source.range((1, 0), (4, 0))
        )
        let applied = try #require(AppliedSemanticCodeConversion(
            conversion, in: source.document
        ))
        let result = try CodeConversionTestValue.applying(
            conversion, to: source.document
        )
        let points = [(0, 2, 2), (1, 0, 0), (1, 2, 2), (2, 0, 3),
                      (2, 2, 5), (2, 3, 6), (3, 0, 8), (3, 1, 9),
                      (3, 2, 10), (4, 3, 3)]
        for start in points
        {
            for end in points
            {
                let selection = DocumentSelection(range: try source.range(
                    (start.0, start.1), (end.0, end.1)
                ))
                let mapped = try #require(applied.selection(
                    selection, from: source.document, to: result
                ))
                for (point, expected) in [
                    (mapped.range.start, start), (mapped.range.end, end)
                ]
                {
                    let index = (1 ... 3).contains(expected.0) ? 1 : expected.0
                    #expect(point.blockID ==
                        source.document.content.blocks[index].blockID)
                    #expect(point.utf16Offset.value == expected.2)
                }
            }
        }
    }

    @Test("splitting maps line ends starts and the terminal empty line")
    func splitCoordinates() throws
    {
        let source = try SemanticWritingTestDocument(
            [.monostyled], texts: ["e\u{301}\r\n\t😀\rA\n"]
        )
        let ids = CodeConversionTestValue.identities(3)
        let conversion = try #require(SemanticCodeConversion(
            range: source.range((0, 0), (0, 0)), proseStyle: .body,
            continuationBlockIDs: ids
        ))
        let applied = try #require(AppliedSemanticCodeConversion(
            conversion, in: source.document
        ))
        let result = try CodeConversionTestValue.applying(
            conversion, to: source.document
        )
        let points = [(0, 0, 0), (2, 0, 2), (4, 1, 0), (5, 1, 1),
                      (7, 1, 3), (8, 2, 0), (9, 2, 1), (10, 3, 0)]
        for start in points
        {
            for end in points
            {
                let mapped = try #require(applied.selection(DocumentSelection(
                    range: source.range((0, start.0), (0, end.0))
                ), from: source.document, to: result))
                for (point, expected) in [
                    (mapped.range.start, start), (mapped.range.end, end)
                ]
                {
                    #expect(point.blockID ==
                        result.content.blocks[expected.1].blockID)
                    #expect(point.utf16Offset.value == expected.2)
                }
            }
        }
    }
}
