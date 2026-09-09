import Testing

@testable import FundamentalDocument

@Suite("Typing inherits exact semantic source")
struct InheritedTypingAttributesTests
{
    @Test("a caret prefers preceding source and ignores empty runs")
    func caretBoundaries() throws
    {
        let scope = SemanticRunScopes.language(
            try #require(SemanticLanguageIdentifier(" ru-RU "))
        )
        let first = SemanticRunAttributes.direct(traits: [.strong])
        let second = SemanticRunAttributes.scoped(traits: [.emphasis],
                                                  scopes: scope)
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "", traits: [.underline]),
                SemanticRun(text: "Ae\u{301}", attributes: first),
                SemanticRun(text: "", traits: [.strikethrough]),
                SemanticRun(text: "😀Z", attributes: second)
            ]))
        ])
        for (offset, attributes) in [(0, first), (1, first), (3, first),
                                      (5, second), (6, second)]
        {
            #expect(try InheritedTypingAttributes(
                source.range((0, offset), (0, offset)), in: source.document
            )?.attributes == attributes)
        }
        for offset in [2, 4, 7]
        {
            #expect(try InheritedTypingAttributes(
                source.range((0, offset), (0, offset)), in: source.document
            ) == nil)
        }
    }

    @Test("selection inheritance follows its first selected source")
    func directedSelection() throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "A", traits: [.strong]),
                SemanticRun(text: "e", traits: [.emphasis]),
                SemanticRun(text: "\u{301}😀", traits: [.underline])
            ]))
        ])
        for range in [try source.range((0, 1), (0, 5)),
                      try source.range((0, 5), (0, 1))]
        {
            #expect(InheritedTypingAttributes(range, in: source.document)?
                .attributes == .direct(traits: [.emphasis]))
        }
        #expect(try InheritedTypingAttributes(
            source.range((0, 5), (0, 5)), in: source.document
        )?.attributes == .direct(traits: [.underline]))
    }
}
