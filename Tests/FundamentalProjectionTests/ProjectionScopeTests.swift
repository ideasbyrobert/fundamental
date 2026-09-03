import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

extension ProjectionProseTests
{
    @Test("every occupied run scope remains distinct")
    func everyOccupiedRunScopeRemainsDistinct() throws
    {
        let link = try #require(SemanticLinkDestination("https://a.test"))
        let language = try #require(SemanticLanguageIdentifier("hy"))
        let scopes: [SemanticRunScopes] = [
            .link(link),
            .language(language),
            .linkAndLanguage(
                link: link,
                language: language
            )
        ]
        let runs = scopes.map
        {
            SemanticRun.scoped(SemanticScopedRun(
                text: "x",
                scopes: $0
            ))
        }
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: runs))
        let projection = try ProjectionFixture.projection([block])
        guard case let .prose(_, prose) = projection.firstBlock
        else
        {
            Issue.record("Expected prose")
            return
        }
        let projected: [ProjectedRunScope] = prose.runs.compactMap
        {
            guard case let .scoped(_, _, _, scope) = $0
            else
            {
                return nil
            }
            return scope
        }
        #expect(projected == [
            .link("https://a.test"),
            .language("hy"),
            .linkAndLanguage(
                link: "https://a.test",
                language: "hy"
            )
        ])
    }
}
