import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticRunTests
{
    @Test("flat scope payloads decode into exact run forms")
    func flatScopePayloadsDecodeIntoExactRunForms() throws
    {
        let link = try #require(SemanticLinkDestination("chapter one"))
        let language = try #require(SemanticLanguageIdentifier("hy"))
        let cases: [(String, SemanticRun)] = [
            (
                #"{"text":"Body","traits":[],"link":"chapter one"}"#,
                .scoped(SemanticScopedRun(
                    text: "Body",
                    scopes: .link(link)
                ))
            ),
            (
                #"{"text":"Body","traits":[],"language":"hy"}"#,
                .scoped(SemanticScopedRun(
                    text: "Body",
                    scopes: .language(language)
                ))
            ),
            (
                #"""
                {"text":"Body","traits":[],"link":"chapter one","language":"hy"}
                """#,
                .scoped(SemanticScopedRun(
                    text: "Body",
                    scopes: .linkAndLanguage(
                        link: link,
                        language: language
                    )
                ))
            )
        ]

        for (payload, expected) in cases
        {
            let decoded = try JSONDecoder().decode(
                SemanticRun.self,
                from: Data(payload.utf8)
            )

            #expect(decoded == expected)
        }
    }

}
