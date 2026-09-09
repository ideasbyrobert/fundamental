import Testing

@testable import FundamentalDocument

extension AppliedSemanticInlineTraitChangeTests
{
    @Test("a grapheme spanning runs retains every exact scope")
    func scopedGrapheme() throws
    {
        let link = try #require(SemanticLinkDestination("https://a.test/é"))
        let language = try #require(SemanticLanguageIdentifier(" ru-RU "))
        let scopes: [SemanticRunScopes] = [
            .link(link), .language(language),
            .linkAndLanguage(link: link, language: language)
        ]
        for scope in scopes
        {
            let empty = SemanticRun(text: "", traits: [.inlineCode])
            let source = try SemanticWritingTestDocument(blocks: [
                .paragraph(SemanticParagraph(runs: [
                    SemanticRun(text: "Ae", traits: [.emphasis]), empty,
                    SemanticRun(text: "\u{301}😀", attributes: .scoped(
                        traits: [.strikethrough], scopes: scope
                    )), SemanticRun(text: "Z")
                ]))
            ])
            let applied = try #require(AppliedSemanticInlineTraitChange(
                SemanticInlineTraitChange(
                    range: source.range((0, 1), (0, 5)),
                    trait: .strong, enabled: true
                ), in: source.document
            ))
            let runs = try CodeConversionTestValue.runs(
                applied.content.blocks[0]
            )
            #expect(runs == [
                SemanticRun(text: "A", traits: [.emphasis]),
                SemanticRun(text: "e", traits: [.emphasis, .strong]), empty,
                SemanticRun(text: "\u{301}😀", attributes: .scoped(
                    traits: [.strikethrough, .strong], scopes: scope
                )), SemanticRun(text: "Z")
            ])
            #expect(runs.flatMap { Array($0.text.utf16) } ==
                Array("Ae\u{301}😀Z".utf16))
        }
    }

    @Test("removing a script preserves the opposite script", arguments:
        [SemanticInlineTrait.superscript, .subscriptText])
    func removeScript(trait: SemanticInlineTrait) throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let change = SemanticInlineTraitChange(
            range: try source.range((0, 0), (0, 4)),
            trait: trait, enabled: false
        )
        let other: SemanticInlineTrait = trait == .superscript
            ? .subscriptText : .superscript
        #expect(change.applying(to: SemanticRun(
            text: "X", traits: [.subscriptText, .superscript, .strong]
        )) == SemanticRun(text: "X", traits: [other, .strong]))
    }
}
