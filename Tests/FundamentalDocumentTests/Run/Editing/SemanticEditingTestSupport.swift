import Testing

@testable import FundamentalDocument

extension SemanticRunAttributesTests
{
    static let traits: Set<SemanticInlineTrait> = [
        .strong,
        .emphasis,
        .inlineCode
    ]

    static func scopes() throws -> [SemanticRunScopes]
    {
        let link = try #require(
            SemanticLinkDestination("chapter-one")
        )
        let language = try #require(
            SemanticLanguageIdentifier("hy")
        )
        return [
            .link(link),
            .language(language),
            .linkAndLanguage(
                link: link,
                language: language
            )
        ]
    }

    static func directRun(
        _ text: String = "Direct"
    ) -> SemanticRun
    {
        .direct(SemanticDirectRun(
            text: text,
            traits: traits
        ))
    }

    static func scopedRun(
        _ scopes: SemanticRunScopes,
        text: String = "Scoped"
    ) -> SemanticRun
    {
        .scoped(SemanticScopedRun(
            text: text,
            traits: traits,
            scopes: scopes
        ))
    }
}
