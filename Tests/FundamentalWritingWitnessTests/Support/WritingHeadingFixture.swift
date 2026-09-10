import Testing

@testable import FundamentalDocument

enum WritingHeadingFixture
{
    static func runs() throws -> [SemanticRun]
    {
        let link = try #require(SemanticLinkDestination(
            " https://example.invalid/e\u{301} "
        ))
        let language = try #require(SemanticLanguageIdentifier(" ru-RU "))
        let scopes = SemanticRunScopes.linkAndLanguage(
            link: link, language: language
        )
        return WritingInlineFixture.traits.enumerated().map
        {
            index, trait in
            .scoped(SemanticScopedRun(text: "\(index)e\u{301}😀 ",
                traits: [trait], scopes: scopes))
        }
    }
}
