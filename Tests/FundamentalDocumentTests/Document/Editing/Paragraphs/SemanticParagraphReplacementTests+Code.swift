import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    @Test(arguments: ["\n", "\r", "\r\n"])
    func codeReplacementPreservesSourceAndLeadingLanguage(ending: String)
        throws
    {
        let language = try #require(SemanticCodeLanguageIdentifier(
            "  SwIfT e\u{301}  "
        ))
        let other = try #require(SemanticCodeLanguageIdentifier("rust"))
        let suffix = "\re\u{301}😀\r\n"
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "Before")])),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: [SemanticRun(text: "A\r\n😀B")], language: language
            ))),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "Middle")])),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: [SemanticRun(text: "C" + suffix)], language: other
            ))),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "After")]))
        ])
        let inserted = "\tX" + ending
        let result = try #require(AppliedSemanticParagraphReplacement(
            source.replacement((1, 3), (3, 1), text: [inserted]),
            in: source.document
        ))
        let blocks = result.document.content.blocks
        #expect(blocks.count == 3)
        #expect(blocks.first == source.document.content.blocks.first)
        #expect(blocks.last == source.document.content.blocks.last)
        #expect(blocks[1].blockID == source.document.content.blocks[1].blockID)
        guard case let .code(.languageTagged(code)) = blocks[1].block
        else
        {
            Issue.record("Expected the leading tagged source block")
            return
        }
        #expect(code.language.value.utf16.elementsEqual(language.value.utf16))
        #expect(code.runs.map(\.text).joined().utf16.elementsEqual(
            ("A\r\n" + inserted + suffix).utf16
        ))
        #expect(result.caret.point.utf16Offset.value ==
            3 + inserted.utf16.count)
    }
}
