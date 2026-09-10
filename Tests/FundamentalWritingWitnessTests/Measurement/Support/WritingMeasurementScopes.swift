import Testing

@testable import FundamentalDocument

enum WritingMeasurementScopes
{
    static func attributes(at index: Int) throws -> SemanticRunAttributes
    {
        let link = try #require(SemanticLinkDestination(
            "https://example.invalid/manuscript"
        ))
        let language = try #require(SemanticLanguageIdentifier("en"))
        let scopes: SemanticRunScopes
        switch index % 3
        {
        case 0:
            scopes = .link(link)
        case 1:
            scopes = .language(language)
        default:
            scopes = .linkAndLanguage(link: link, language: language)
        }
        return .scoped(traits: [], scopes: scopes)
    }
}
