import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticRunTests
{
    @Test("all run forms round trip semantically")
    func allRunFormsRoundTripSemantically() throws
    {
        let link = try #require(SemanticLinkDestination("chapter one"))
        let language = try #require(SemanticLanguageIdentifier("hy"))
        let runs: [SemanticRun] = [
            SemanticRun(text: "Direct"),
            .scoped(SemanticScopedRun(
                text: "Linked",
                scopes: .link(link)
            )),
            .scoped(SemanticScopedRun(
                text: "Localized",
                scopes: .language(language)
            )),
            .scoped(SemanticScopedRun(
                text: "Բարև 😀",
                traits: [.strong, .emphasis, .inlineCode],
                scopes: .linkAndLanguage(
                    link: link,
                    language: language
                )
            ))
        ]

        for run in runs
        {
            let data = try JSONEncoder().encode(run)
            let decoded = try JSONDecoder().decode(
                SemanticRun.self,
                from: data
            )

            #expect(decoded == run)
        }
    }
}
