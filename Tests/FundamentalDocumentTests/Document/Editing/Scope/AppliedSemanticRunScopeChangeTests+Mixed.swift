import Testing

@testable import FundamentalDocument

extension AppliedSemanticRunScopeChangeTests
{
    @Test("matching boundary runs stay whole beside changed scoped text")
    func mixedBoundaries() throws
    {
        let matched = try ScopeTestValue.attributes(
            link: ScopeTestValue.newLink
        )
        let old = try ScopeTestValue.attributes(link: ScopeTestValue.oldLink)
        let empty = SemanticRun(text: "", attributes: old)
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "AB", attributes: matched), empty,
                SemanticRun(text: "CD", attributes: old),
                SemanticRun(text: "EF", attributes: matched)
            ]))
        ])
        let applied = try #require(AppliedSemanticRunScopeChange(
            SemanticRunScopeChange(range: source.range((0, 1), (0, 5)),
                assignment: ScopeTestValue.assignments()[0]),
            in: source.document
        ))
        #expect(try CodeConversionTestValue.runs(applied.content.blocks[0]) == [
            SemanticRun(text: "AB", attributes: matched), empty,
            SemanticRun(text: "CD", attributes: matched),
            SemanticRun(text: "EF", attributes: matched)
        ])
    }

    @Test("a grapheme across runs preserves each language and trait")
    func scopedGrapheme() throws
    {
        let first = try ScopeTestValue.attributes(
            language: "ru", traits: [.strong]
        )
        let last = try ScopeTestValue.attributes(
            language: "en", traits: [.emphasis]
        )
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "Ae", attributes: first),
                SemanticRun(text: "\u{301}😀Z", attributes: last)
            ]))
        ])
        let applied = try #require(AppliedSemanticRunScopeChange(
            SemanticRunScopeChange(range: source.range((0, 1), (0, 5)),
                assignment: ScopeTestValue.assignments()[0]),
            in: source.document
        ))
        let linkedFirst = try ScopeTestValue.attributes(
            link: ScopeTestValue.newLink, language: "ru", traits: [.strong]
        )
        let linkedLast = try ScopeTestValue.attributes(
            link: ScopeTestValue.newLink, language: "en", traits: [.emphasis]
        )
        #expect(try CodeConversionTestValue.runs(applied.content.blocks[0]) == [
            SemanticRun(text: "A", attributes: first),
            SemanticRun(text: "e", attributes: linkedFirst),
            SemanticRun(text: "\u{301}😀", attributes: linkedLast),
            SemanticRun(text: "Z", attributes: last)
        ])
    }
}
