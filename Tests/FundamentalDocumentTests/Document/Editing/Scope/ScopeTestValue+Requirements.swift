import Testing

@testable import FundamentalDocument

extension ScopeTestValue
{
    static func link(_ value: String) throws -> SemanticLinkDestination
    {
        try #require(SemanticLinkDestination(value))
    }

    static func language(_ value: String) throws -> SemanticLanguageIdentifier
    {
        try #require(SemanticLanguageIdentifier(value))
    }
}
