@testable import FundamentalParagraph
import FundamentalNativeParagraph
import FundamentalDocument
import Testing

enum WordFixture
{
    static func language(_ value: String) throws -> SemanticLanguageIdentifier
    {
        try #require(SemanticLanguageIdentifier(value))
    }

    static func run(
        _ text: String, traits: Set<SemanticInlineTrait> = []
    ) -> SemanticRun
    {
        SemanticRun(text: text, attributes: .direct(traits: traits))
    }

    static func scoped(
        _ text: String, _ scopes: SemanticRunScopes,
        traits: Set<SemanticInlineTrait> = []
    ) -> SemanticRun
    {
        SemanticRun(text: text, attributes: .scoped(
            traits: traits, scopes: scopes
        ))
    }

    static func source(
        _ runs: [SemanticRun], language: String = "en_US"
    ) throws -> ParagraphWordSource
    {
        ParagraphWordSource(
            SemanticParagraph(runs: runs),
            defaultLanguage: try Self.language(language)
        )
    }

    static func resolved(
        _ resolution: WordScopeResolution
    ) throws -> ResolvedWordScope
    {
        guard case let .resolved(scope) = resolution
        else
        {
            Issue.record("Unexpected scope refusal: \(resolution)")
            throw WordFixtureFailure.invalidValue
        }
        return scope
    }
}
