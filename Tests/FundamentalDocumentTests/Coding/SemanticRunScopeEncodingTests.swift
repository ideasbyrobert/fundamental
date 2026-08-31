import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticRunTests
{
    @Test("scoped runs encode flat scope keys")
    func scopedRunsEncodeFlatScopeKeys() throws
    {
        let link = try #require(SemanticLinkDestination("chapter one"))
        let language = try #require(SemanticLanguageIdentifier("hy"))
        let linked = try encodedScopeObject(
            for: .scoped(SemanticScopedRun(
                text: "Body",
                scopes: .link(link)
            ))
        )
        let localized = try encodedScopeObject(
            for: .scoped(SemanticScopedRun(
                text: "Body",
                scopes: .language(language)
            ))
        )
        let combined = try encodedScopeObject(
            for: .scoped(SemanticScopedRun(
                text: "Body",
                scopes: .linkAndLanguage(
                    link: link,
                    language: language
                )
            ))
        )

        #expect(Set(linked.keys) == Set(["link", "text", "traits"]))
        #expect(linked["link"] as? String == link.value)
        #expect(Set(localized.keys) == Set([
            "language",
            "text",
            "traits"
        ]))
        #expect(localized["language"] as? String == language.value)
        #expect(Set(combined.keys) == Set([
            "language",
            "link",
            "text",
            "traits"
        ]))
        #expect(combined["link"] as? String == link.value)
        #expect(combined["language"] as? String == language.value)
    }

    private func encodedScopeObject(
        for run: SemanticRun
    ) throws -> [String: Any]
    {
        let data = try JSONEncoder().encode(run)
        return try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
    }
}
