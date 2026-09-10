import Testing

@testable import FundamentalDocument

extension MacReaderDocumentFixture
{
    static func scopedParagraph() throws -> SemanticBlock
    {
        let link = try #require(SemanticLinkDestination(
            "https://example.invalid/e\u{301}"
        ))
        let language = try #require(SemanticLanguageIdentifier("ru-RU"))
        return .paragraph(SemanticParagraph(runs: [
            SemanticRun(text: "Direct "),
            .scoped(SemanticScopedRun(
                text: "Link e\u{301} ", traits: [.underline],
                scopes: .link(link)
            )),
            .scoped(SemanticScopedRun(
                text: "Язык ", scopes: .language(language)
            )),
            .scoped(SemanticScopedRun(
                text: "Both 👩🏽‍💻",
                scopes: .linkAndLanguage(link: link, language: language)
            ))
        ]))
    }
}
