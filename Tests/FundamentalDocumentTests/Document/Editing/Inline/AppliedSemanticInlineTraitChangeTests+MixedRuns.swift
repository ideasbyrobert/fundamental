import Testing

@testable import FundamentalDocument

extension AppliedSemanticInlineTraitChangeTests
{
    @Test("matching boundary runs remain whole inside a mixed selection")
    func mixedRunBoundaries() throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "AB", traits: [.strong]),
                SemanticRun(text: "CD"),
                SemanticRun(text: "EF", traits: [.strong])
            ]))
        ])
        let applied = try #require(AppliedSemanticInlineTraitChange(
            SemanticInlineTraitChange(
                range: source.range((0, 1), (0, 5)),
                trait: .strong, enabled: true
            ), in: source.document
        ))
        #expect(try CodeConversionTestValue.runs(applied.content.blocks[0]) == [
            SemanticRun(text: "AB", traits: [.strong]),
            SemanticRun(text: "CD", traits: [.strong]),
            SemanticRun(text: "EF", traits: [.strong])
        ])
    }
}
