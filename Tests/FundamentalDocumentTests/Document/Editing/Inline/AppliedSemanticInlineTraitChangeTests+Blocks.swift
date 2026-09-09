import Testing

@testable import FundamentalDocument

extension AppliedSemanticInlineTraitChangeTests
{
    @Test("all editable roles preserve exact source and identities")
    func blockRoles() throws
    {
        let spelling = "\te\u{301}😀\r\nZ\r"
        let runs = [SemanticRun(text: spelling)]
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
        let applied = try #require(AppliedSemanticInlineTraitChange(
            SemanticInlineTraitChange(
                range: source.range((blocks.count - 1, spelling.utf16.count),
                                    (0, 0)),
                trait: .strong, enabled: true
            ), in: source.document
        ))
        for (before, after) in zip(source.document.content.blocks,
                                   applied.content.blocks)
        {
            #expect(after.blockID == before.blockID)
            #expect(CanonicalBlockStyle(after.block) ==
                CanonicalBlockStyle(before.block))
            if case let .heading(.section(heading)) = before.block
            {
                #expect(after.block == .heading(.section(
                    SectionSemanticHeading(
                        runs: [SemanticRun(text: spelling, traits: [.strong])],
                        level: heading.level
                    )
                )))
            }
            let result = try CodeConversionTestValue.runs(after)
            #expect(result == [SemanticRun(text: spelling, traits: [.strong])])
            #expect(result.flatMap { Array($0.text.utf16) } ==
                Array(spelling.utf16))
        }
        guard case let .code(.languageTagged(code)) =
            applied.content.blocks[blocks.count - 1].block
        else
        {
            Issue.record("Expected retained code language")
            return
        }
        #expect(code.language.value.utf16.elementsEqual(" SwIfT ".utf16))
    }

    @Test("an upper endpoint at zero excludes the following block")
    func halfOpenBlocks() throws
    {
        let source = try SemanticWritingTestDocument([.body, .numbered])
        let applied = try #require(AppliedSemanticInlineTraitChange(
            SemanticInlineTraitChange(
                range: source.range((0, 2), (1, 0)),
                trait: .emphasis, enabled: true
            ), in: source.document
        ))
        #expect(applied.content.blocks[1] == source.document.content.blocks[1])
        #expect(try CodeConversionTestValue.runs(applied.content.blocks[0]) == [
            SemanticRun(text: "AB"),
            SemanticRun(text: "CD", traits: [.emphasis])
        ])
    }
}
