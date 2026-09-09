import Testing

@testable import FundamentalDocument

extension AppliedSemanticCodeConversionTests
{
    @Test("multiple code blocks consume fresh identities in source order")
    func multipleCodeBlocks() throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            CodeConversionTestValue.code([SemanticRun(text: "A\r\nB")]),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "C")])),
            CodeConversionTestValue.code(
                [SemanticRun(text: "X\nY\n")], language: " Swift "
            ),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "After")]))
        ])
        let ids = CodeConversionTestValue.identities(3)
        let conversion = try #require(SemanticCodeConversion(
            range: source.range((0, 0), (3, 0)), proseStyle: .bulleted,
            continuationBlockIDs: ids
        ))
        let result = try CodeConversionTestValue.applying(
            conversion, to: source.document
        )
        CodeConversionTestValue.expectText(
            result, ["A", "B", "C", "X", "Y", "", "After"]
        )
        let original = source.document.content.blocks
        #expect(result.content.blocks.map(\.blockID) ==
            [original[0].blockID, ids[0], original[1].blockID,
             original[2].blockID, ids[1], ids[2], original[3].blockID])
        #expect(result.content.blocks.dropLast().allSatisfy
            { CanonicalBlockStyle($0.block) == .bulleted })
        #expect(result.content.blocks.last == original.last)
    }
}
