import Testing

@testable import FundamentalDocument

extension AppliedSemanticRunScopeChangeTests
{
    @Test("every non-table role retains identity meaning and code language")
    func blockRoles() throws
    {
        let text = "\te\u{301}😀\r\nZ\r"
        let before = try ScopeTestValue.attributes(link: ScopeTestValue.oldLink)
        let after = try ScopeTestValue.attributes(
            link: ScopeTestValue.oldLink, language: ScopeTestValue.newLanguage
        )
        let runs = [SemanticRun(text: text, attributes: before)]
        var blocks = CanonicalBlockStyle.allCases.map
        {
            $0.semanticBlock(runs: runs)
        }
        blocks += SemanticHeadingLevel.allCases.map
        {
            .heading(.section(SectionSemanticHeading(runs: runs, level: $0)))
        }
        blocks.append(try CodeConversionTestValue.code(
            runs, language: " SwIfT "
        ))
        let source = try SemanticWritingTestDocument(blocks: blocks)
        let range = try source.range(
            (blocks.count - 1, text.utf16.count), (0, 0)
        )
        let applied = try #require(AppliedSemanticRunScopeChange(
            SemanticRunScopeChange(range: range,
                assignment: ScopeTestValue.assignments()[2]
            ), in: source.document
        ))
        for (original, changed) in zip(source.document.content.blocks,
                                       applied.content.blocks)
        {
            #expect(changed.blockID == original.blockID)
            #expect(CanonicalBlockStyle(changed.block) ==
                CanonicalBlockStyle(original.block))
            let expected = [SemanticRun(text: text, attributes: after)]
            #expect(try CodeConversionTestValue.runs(changed) == expected)
            if case let .heading(.section(heading)) = original.block
            {
                #expect(changed.block == .heading(.section(
                    SectionSemanticHeading(runs: expected, level: heading.level)
                )))
            }
        }
        guard case let .code(.languageTagged(code)) =
            applied.content.blocks[blocks.count - 1].block
        else
        {
            Issue.record("Expected the exact code-language label")
            return
        }
        #expect(code.language.value.utf16.elementsEqual(" SwIfT ".utf16))
    }
}
