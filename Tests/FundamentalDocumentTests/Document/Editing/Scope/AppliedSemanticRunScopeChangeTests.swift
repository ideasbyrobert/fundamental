import Testing

@testable import FundamentalDocument

@Suite("Scoped formatting preserves selected source")
struct AppliedSemanticRunScopeChangeTests
{
    @Test("partial scope assignment preserves other facts", arguments:
        0..<4, 0..<4)
    func partialRange(form: Int, operation: Int) throws
    {
        let oldLink = ScopeTestValue.oldLink
        let newLink = ScopeTestValue.newLink
        let oldLanguage = ScopeTestValue.oldLanguage
        let newLanguage = ScopeTestValue.newLanguage
        let original = try ScopeTestValue.attributes(
            link: form == 1 || form == 3 ? oldLink : nil,
            language: form >= 2 ? oldLanguage : nil
        )
        let targets: [[(String?, String?)]] = [
            [(newLink, nil), (newLink, nil),
             (newLink, oldLanguage), (newLink, oldLanguage)],
            [(nil, nil), (nil, nil),
             (nil, oldLanguage), (nil, oldLanguage)],
            [(nil, newLanguage), (oldLink, newLanguage),
             (nil, newLanguage), (oldLink, newLanguage)],
            [(nil, nil), (oldLink, nil), (nil, nil), (oldLink, nil)]
        ]
        let target = targets[operation][form]
        let expected = try ScopeTestValue.attributes(
            link: target.0, language: target.1
        )
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(
                text: "Ae\u{301}😀Z", attributes: original
            )]))
        ])
        let applied = try #require(AppliedSemanticRunScopeChange(
            SemanticRunScopeChange(range: source.range((0, 1), (0, 5)),
                assignment: ScopeTestValue.assignments()[operation]),
            in: source.document
        ))
        let block = applied.content.blocks[0]
        #expect(block.blockID == source.document.content.blocks[0].blockID)
        let runs = try CodeConversionTestValue.runs(block)
        if expected == original
        {
            #expect(applied.content == source.document.content)
        }
        else
        {
            #expect(runs == [
                SemanticRun(text: "A", attributes: original),
                SemanticRun(text: "e\u{301}😀", attributes: expected),
                SemanticRun(text: "Z", attributes: original)
            ])
        }
        #expect(runs.flatMap { Array($0.text.utf16) } ==
            Array("Ae\u{301}😀Z".utf16))
    }
}
