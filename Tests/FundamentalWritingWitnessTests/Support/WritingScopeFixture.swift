import Testing

@testable import FundamentalDocument

enum WritingScopeFixture
{
    static let link = " https://example.invalid/e\u{301} "
    static let language = " ru-RU "

    static func scopes() throws -> [SemanticRunScopes]
    {
        let destination = try #require(SemanticLinkDestination(link))
        let identifier = try #require(SemanticLanguageIdentifier(language))
        return [.link(destination), .language(identifier),
                .linkAndLanguage(link: destination, language: identifier)]
    }

    static func run(
        _ text: String, form: Int, traits: Set<SemanticInlineTrait> = []
    ) throws -> SemanticRun
    {
        SemanticRun(text: text, attributes: .scoped(
            traits: traits, scopes: try scopes()[form]
        ))
    }
}
