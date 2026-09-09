import Testing

@testable import FundamentalDocument

@Suite("Canonical code conversion preserves source meaning")
struct AppliedSemanticCodeConversionTests
{
    @Test("joining mixed roles retains every run and first block identity")
    func joinMixedRoles() throws
    {
        let runs = try BlockRecordTestValue.runs()
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "Before")])),
            .heading(.section(SectionSemanticHeading(runs: runs, level: .six))),
            .listItem(SemanticListItem(kind: .numbered, runs: runs)),
            CodeConversionTestValue.code(runs, language: " Old "),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "After")]))
        ])
        let language = try #require(SemanticCodeLanguageIdentifier(" SwIfT "))
        let result = try CodeConversionTestValue.applying(
            SemanticCodeConversion(
                range: source.range((1, 0), (4, 0)), codeLanguage: language
            ),
            to: source.document
        )
        let original = source.document.content.blocks
        let blocks = result.content.blocks
        #expect(blocks.count == 3)
        #expect(blocks[0] == original[0])
        #expect(blocks[2] == original[4])
        #expect(blocks[1].blockID == original[1].blockID)
        let expected = runs + [SemanticRun(text: "\n")] + runs +
            [SemanticRun(text: "\n")] + runs
        #expect(try CodeConversionTestValue.runs(blocks[1]) == expected)
        guard case let .code(.languageTagged(code)) = blocks[1].block
        else
        {
            Issue.record("Expected one language-tagged code block")
            return
        }
        #expect(code.language.value.utf16.elementsEqual(" SwIfT ".utf16))
        #expect(code.runs.map(\.text).joined().utf16.elementsEqual(
            expected.map(\.text).joined().utf16
        ))
    }

    @Test("an explicit plain target removes the tag without changing runs")
    func removeCodeLanguage() throws
    {
        let runs = try BlockRecordTestValue.runs()
        let source = try SemanticWritingTestDocument(blocks: [
            CodeConversionTestValue.code(runs, language: " SwIfT ")
        ])
        let result = try CodeConversionTestValue.applying(
            SemanticCodeConversion(range: source.range((0, 0), (0, 0))),
            to: source.document
        )
        #expect(result.content.blocks[0].blockID ==
            source.document.content.blocks[0].blockID)
        #expect(result.content.blocks[0].block ==
            .code(.plain(PlainSemanticCodeBlock(runs: runs))))
    }
}
