import Testing

@testable import FundamentalDocument

extension AppliedSemanticRunScopeChangeTests
{
    @Test("empty and separator-only ranges do not invent scoped source")
    func emptyRanges() throws
    {
        let empty = SemanticRun(text: "", attributes:
            try ScopeTestValue.attributes(link: ScopeTestValue.oldLink))
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "A")])),
            .paragraph(SemanticParagraph(runs: [empty])),
            .paragraph(SemanticParagraph(runs: [])),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "B")]))
        ])
        for range in [try source.range((0, 0), (0, 0)),
                      try source.range((0, 1), (3, 0))]
        {
            let applied = try #require(AppliedSemanticRunScopeChange(
                SemanticRunScopeChange(range: range,
                    assignment: ScopeTestValue.assignments()[0]),
                in: source.document
            ))
            #expect(applied.content == source.document.content)
        }
    }

    @Test("a half-open endpoint leaves the next block unchanged")
    func halfOpen() throws
    {
        let source = try SemanticWritingTestDocument([.body, .numbered])
        let applied = try #require(AppliedSemanticRunScopeChange(
            SemanticRunScopeChange(
                range: source.range((0, 2), (1, 0)),
                assignment: ScopeTestValue.assignments()[0]),
            in: source.document
        ))
        let expected = try ScopeTestValue.attributes(
            link: ScopeTestValue.newLink, traits: []
        )
        #expect(applied.content.blocks[1] == source.document.content.blocks[1])
        #expect(try CodeConversionTestValue.runs(applied.content.blocks[0]) == [
            SemanticRun(text: "AB"),
            SemanticRun(text: "CD", attributes: expected)
        ])
    }
}
