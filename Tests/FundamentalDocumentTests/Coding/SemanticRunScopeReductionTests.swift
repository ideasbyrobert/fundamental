import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticRunTests
{
    @Test("missing null and blank scope values are omitted")
    func missingNullAndBlankScopeValuesAreOmitted() throws
    {
        let directPayloads = [
            #"{"text":"Body","traits":[]}"#,
            #"{"text":"Body","traits":[],"link":null,"language":null}"#,
            #"{"text":"Body","traits":[],"link":"","language":" \t"}"#
        ]

        for payload in directPayloads
        {
            let decoded = try JSONDecoder().decode(
                SemanticRun.self,
                from: Data(payload.utf8)
            )

            #expect(decoded == SemanticRun(text: "Body"))
        }

        let link = try #require(SemanticLinkDestination("chapter one"))
        let language = try #require(SemanticLanguageIdentifier("hy"))
        let reducedCases: [(String, SemanticRun)] = [
            (
                #"{"text":"Body","traits":[],"link":" ","language":"hy"}"#,
                .scoped(SemanticScopedRun(
                    text: "Body",
                    scopes: .language(language)
                ))
            ),
            (
                #"""
                {"text":"Body","traits":[],"link":"chapter one","language":""}
                """#,
                .scoped(SemanticScopedRun(
                    text: "Body",
                    scopes: .link(link)
                ))
            )
        ]

        for (payload, expected) in reducedCases
        {
            let decoded = try JSONDecoder().decode(
                SemanticRun.self,
                from: Data(payload.utf8)
            )

            #expect(decoded == expected)
        }
    }
}
