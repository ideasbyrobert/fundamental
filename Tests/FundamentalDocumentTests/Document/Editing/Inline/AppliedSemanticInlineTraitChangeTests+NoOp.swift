import Testing

@testable import FundamentalDocument

extension AppliedSemanticInlineTraitChangeTests
{
    @Test("already matching source retains its exact original run shape")
    func noRunSplitting() throws
    {
        let original = [
            SemanticRun(text: "ABCD", traits: [.strong]),
            SemanticRun(text: "", traits: [.emphasis]),
            SemanticRun(text: "E", traits: [.strong])
        ]
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: original))
        ])
        for (trait, enabled) in [(SemanticInlineTrait.strong, true),
                                 (.underline, false)]
        {
            let applied = try #require(AppliedSemanticInlineTraitChange(
                SemanticInlineTraitChange(
                    range: source.range((0, 1), (0, 3)),
                    trait: trait, enabled: enabled
                ), in: source.document
            ))
            #expect(applied.content == source.document.content)
        }
    }

    @Test("collapsed and separator-only selections do not format empty runs")
    func emptySelection() throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "A")])),
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "", traits: [.emphasis])
            ])),
            .paragraph(SemanticParagraph(runs: [])),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "B")]))
        ])
        for range in [try source.range((0, 0), (0, 0)),
                      try source.range((0, 1), (3, 0))]
        {
            let applied = try #require(AppliedSemanticInlineTraitChange(
                SemanticInlineTraitChange(
                    range: range, trait: .strong, enabled: true
                ), in: source.document
            ))
            #expect(applied.content == source.document.content)
        }
    }
}
