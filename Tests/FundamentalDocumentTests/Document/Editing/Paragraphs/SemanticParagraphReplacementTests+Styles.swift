import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    @Test("heading continuations become body while lists retain their kind")
    func semanticContinuation() throws
    {
        let styles = CanonicalBlockStyle.allCases.filter { $0 != .monostyled }
        for style in styles
        {
            let source = try SemanticWritingTestDocument([style])
            let edit = try source.replacement(
                (0, 2), (0, 2), text: ["", "X", ""]
            )
            let result = try #require(AppliedSemanticParagraphReplacement(
                edit, in: source.document
            ))
            let continuation: CanonicalBlockStyle =
                [.title, .heading, .subheading].contains(style) ? .body : style
            #expect(result.document.content.blocks.map
                { CanonicalBlockStyle($0.block) } ==
                [style, continuation, continuation])
            #expect(SemanticWritingTestDocument.texts(result.document) ==
                ["AB", "X", "CD"])
            #expect(result.caret.point.utf16Offset.value == 0)
            #expect(result.document.content.blocks[0].blockID ==
                source.document.content.blocks[0].blockID)
        }
    }

    @Test("mixed block replacement keeps the leading role and outside blocks")
    func mixedReplacement() throws
    {
        let source = try SemanticWritingTestDocument(
            [.title, .bulleted, .heading, .numbered, .body]
        )
        let edit = try source.replacement((1, 1), (3, 3), text: ["é😀"])
        let result = try #require(AppliedSemanticParagraphReplacement(
            edit, in: source.document
        ))
        #expect(SemanticWritingTestDocument.texts(result.document) ==
            ["ABCD", "Aé😀D", "ABCD"])
        #expect(result.document.content.blocks.map
            { CanonicalBlockStyle($0.block) } == [.title, .bulleted, .body])
        #expect(result.document.content.blocks.first ==
            source.document.content.blocks.first)
        #expect(result.document.content.blocks.last ==
            source.document.content.blocks.last)
        #expect(result.caret.point.utf16Offset.value == 4)
    }

    @Test("an empty list item can split without manufacturing marker text")
    func emptyListSplit() throws
    {
        let source = try SemanticWritingTestDocument([.numbered], texts: [""])
        let result = try #require(AppliedSemanticParagraphReplacement(
            source.replacement((0, 0), (0, 0), text: ["", ""]),
            in: source.document
        ))
        #expect(SemanticWritingTestDocument.texts(result.document) == ["", ""])
        #expect(result.document.content.blocks.allSatisfy
            { CanonicalBlockStyle($0.block) == .numbered })
    }
}
