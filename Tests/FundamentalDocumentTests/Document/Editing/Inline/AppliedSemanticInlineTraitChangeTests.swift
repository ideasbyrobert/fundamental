import Testing

@testable import FundamentalDocument

@Suite("Inline traits preserve selected source")
struct AppliedSemanticInlineTraitChangeTests
{
    static let traits: [SemanticInlineTrait] = [
        .strong, .emphasis, .underline, .strikethrough, .inlineCode,
        .superscript, .subscriptText
    ]

    @Test("each trait changes only the selected Unicode", arguments:
        traits, [true, false])
    func partialRange(trait: SemanticInlineTrait, enabled: Bool) throws
    {
        let other: Set<SemanticInlineTrait> = [
            trait == .underline ? .strong : .underline
        ]
        let initial = enabled ? other : other.union([trait])
        let expected = enabled ? other.union([trait]) : other
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "Ae\u{301}😀Z", traits: initial)
            ]))
        ])
        let applied = try #require(AppliedSemanticInlineTraitChange(
            SemanticInlineTraitChange(
                range: source.range((0, 1), (0, 5)),
                trait: trait, enabled: enabled
            ), in: source.document
        ))
        let block = applied.content.blocks[0]
        #expect(block.blockID == source.document.content.blocks[0].blockID)
        let runs = try CodeConversionTestValue.runs(block)
        #expect(runs == [
            SemanticRun(text: "A", traits: initial),
            SemanticRun(text: "e\u{301}😀", traits: expected),
            SemanticRun(text: "Z", traits: initial)
        ])
        #expect(runs.flatMap { Array($0.text.utf16) } ==
            Array("Ae\u{301}😀Z".utf16))
    }

    @Test("script exclusivity changes only the selected source", arguments:
        [SemanticInlineTrait.superscript, .subscriptText])
    func scriptExclusivity(trait: SemanticInlineTrait) throws
    {
        let both: Set<SemanticInlineTrait> = [
            .superscript, .subscriptText, .emphasis
        ]
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "ABC", traits: both)
            ]))
        ])
        let applied = try #require(AppliedSemanticInlineTraitChange(
            SemanticInlineTraitChange(
                range: source.range((0, 1), (0, 2)),
                trait: trait, enabled: true
            ), in: source.document
        ))
        #expect(try CodeConversionTestValue.runs(applied.content.blocks[0]) == [
            SemanticRun(text: "A", traits: both),
            SemanticRun(text: "B", traits: [.emphasis, trait]),
            SemanticRun(text: "C", traits: both)
        ])
    }
}
