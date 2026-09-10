import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    @Test(arguments: CanonicalBlockStyle.allCases)
    func retainedCodeLinesKeepTheirSourceAndLeadingRole(
        style: CanonicalBlockStyle
    ) throws
    {
        let suffix = "\r\n\t😀e\u{301}\r\n\n\r"
        let retained = SemanticRun(text: "C" + suffix, traits: [.strong])
        let source = try SemanticWritingTestDocument(blocks: [
            style.semanticBlock(runs: [SemanticRun(text: "AB")]),
            .code(.plain(PlainSemanticCodeBlock(runs: [retained])))
        ])
        let result = try #require(AppliedSemanticParagraphReplacement(
            source.replacement((0, 1), (1, 1), text: ["X", "Y"]),
            in: source.document
        ))
        let blocks = result.document.content.blocks
        let continuation: CanonicalBlockStyle =
            style.semanticKind == .heading ? .body : style
        #expect(blocks.map { CanonicalBlockStyle($0.block) } ==
            [style, continuation])
        #expect(SemanticWritingTestDocument.texts(result.document)[0] == "AX")
        let last = try #require(EditableSemanticBlock(blocks[1].block))
        #expect(last.runs.map(\.text).joined().utf16.elementsEqual(
            ("Y" + suffix).utf16
        ))
        #expect(last.runs.last?.attributes == retained.attributes)
        #expect(result.caret.point.blockID == blocks[1].blockID)
        #expect(result.caret.point.utf16Offset.value == 1)
    }

    @Test(arguments: ["\n", "\r", "\r\n", "\t\r\n\n😀e\u{301}"])
    func replacementPayloadPreservesHardLineBreaks(text: String) throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: ["AB"])
        let result = try #require(AppliedSemanticParagraphReplacement(
            source.replacement((0, 1), (0, 1), text: [text]),
            in: source.document
        ))
        #expect(result.document.content.blocks.count == 1)
        #expect(SemanticWritingTestDocument.texts(result.document)[0].utf16
            .elementsEqual(("A" + text + "B").utf16))
        #expect(result.caret.point.utf16Offset.value == 1 + text.utf16.count)
    }
}
