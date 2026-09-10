import Testing

@testable import FundamentalDocument

enum ScopeTestValue
{
    static let oldLink = " https://a.test/é "
    static let newLink = " https://a.test/e\u{301} "
    static let oldLanguage = " ru-RU "
    static let newLanguage = " en-US "
    static let traits: Set<SemanticInlineTrait> = [
        .strong, .emphasis, .underline, .strikethrough, .inlineCode,
        .superscript, .subscriptText
    ]

    static func attributes(
        link: String? = nil, language: String? = nil,
        traits: Set<SemanticInlineTrait> = ScopeTestValue.traits
    ) throws -> SemanticRunAttributes
    {
        let link = try link.map { try #require(SemanticLinkDestination($0)) }
        let language = try language.map
        {
            try #require(SemanticLanguageIdentifier($0))
        }
        let scopes: SemanticRunScopes
        if let link, let language
        {
            scopes = .linkAndLanguage(link: link, language: language)
        }
        else if let link
        {
            scopes = .link(link)
        }
        else if let language
        {
            scopes = .language(language)
        }
        else
        {
            return .direct(traits: traits)
        }
        return .scoped(traits: traits, scopes: scopes)
    }

    static func assignments() throws -> [SemanticRunScopeAssignment]
    {
        [.link(try #require(SemanticLinkDestination(newLink))), .link(nil),
         .language(try #require(SemanticLanguageIdentifier(newLanguage))),
         .language(nil)]
    }
}
