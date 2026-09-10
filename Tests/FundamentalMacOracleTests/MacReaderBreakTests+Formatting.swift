import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension MacReaderBreakTests
{
    @Test("styled hard breaks preserve exact native source copying",
          arguments: MacReaderBreakKind.allCases, [
            SemanticInlineTrait.strong, .emphasis, .underline,
            .strikethrough, .inlineCode, .superscript, .subscriptText
          ])
    func styled(kind: MacReaderBreakKind, trait: SemanticInlineTrait) throws
    {
        let text = "A\r\n"
        let selection = try MacReaderBreakFixture.copy(kind.block(runs: [
            SemanticRun(text: text, traits: [trait])
        ]))
        #expect(selection.text.utf16.elementsEqual(text.utf16))
        #expect(selection.firstFragment.range == 0 ..< 3)
        #expect(selection.firstFragment.logicalBounds.size.width > 0)
    }

    @Test("all four scopes survive hard-break selection and native copy",
          arguments: MacReaderBreakKind.allCases)
    func scopes(kind: MacReaderBreakKind) throws
    {
        let link = try #require(SemanticLinkDestination("https://a.test"))
        let language = try #require(SemanticLanguageIdentifier("ru-RU"))
        let selection = try MacReaderBreakFixture.copy(kind.block(runs: [
            SemanticRun(text: "\n"),
            .scoped(SemanticScopedRun(text: "\r\n", scopes: .link(link))),
            .scoped(SemanticScopedRun(
                text: "\u{2028}", scopes: .language(language)
            )),
            .scoped(SemanticScopedRun(
                text: "\u{2029}",
                scopes: .linkAndLanguage(link: link, language: language)
            ))
        ]))
        #expect(selection.text.utf16.elementsEqual(
            "\n\r\n\u{2028}\u{2029}".utf16
        ))
        #expect(selection.sourceSlices.map(\.scope) == [
            .direct, .link("https://a.test"), .language("ru-RU"),
            .linkAndLanguage(link: "https://a.test", language: "ru-RU")
        ])
        #expect(selection.sourceSlices.map(\.range) == [
            0 ..< 1, 1 ..< 3, 3 ..< 4, 4 ..< 5
        ])
        #expect(selection.fragments.count == 4)
    }
}
