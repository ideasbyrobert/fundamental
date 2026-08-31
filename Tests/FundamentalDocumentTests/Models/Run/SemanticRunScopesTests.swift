import Testing

@testable import FundamentalDocument

@Suite("Semantic run scopes")
struct SemanticRunScopesTests
{
    @Test("a link scope contains only its destination")
    func linkScopeContainsOnlyItsDestination() throws
    {
        let link = try #require(SemanticLinkDestination("chapter one"))
        let scopes = SemanticRunScopes.link(link)

        guard case let .link(admitted) = scopes
        else
        {
            Issue.record("Expected a link scope")
            return
        }

        #expect(admitted == link)
    }

    @Test("a language scope contains only its identifier")
    func languageScopeContainsOnlyItsIdentifier() throws
    {
        let language = try #require(SemanticLanguageIdentifier("hy"))
        let scopes = SemanticRunScopes.language(language)

        guard case let .language(admitted) = scopes
        else
        {
            Issue.record("Expected a language scope")
            return
        }

        #expect(admitted == language)
    }

    @Test("a combined scope contains both unique facts")
    func combinedScopeContainsBothUniqueFacts() throws
    {
        let link = try #require(SemanticLinkDestination("chapter one"))
        let language = try #require(SemanticLanguageIdentifier("hy"))
        let scopes = SemanticRunScopes.linkAndLanguage(
            link: link,
            language: language
        )

        guard case let .linkAndLanguage(
            admittedLink,
            admittedLanguage
        ) = scopes
        else
        {
            Issue.record("Expected combined scopes")
            return
        }

        #expect(admittedLink == link)
        #expect(admittedLanguage == language)
    }
}
