import Testing

@testable import FundamentalDocument

struct HeadingTestValue
{
    static func runs() throws -> [SemanticRun]
    {
        let link = try #require(SemanticLinkDestination(
            " https://example.test/e\u{301} "
        ))
        let language = try #require(SemanticLanguageIdentifier(" ru "))
        return [
            SemanticRun(text: ""),
            .scoped(SemanticScopedRun(
                text: "e\u{301}😀",
                traits: [.strong, .emphasis, .underline,
                         .strikethrough, .inlineCode],
                scopes: .linkAndLanguage(link: link, language: language)
            )),
            .scoped(SemanticScopedRun(text: "L", traits: [.superscript],
                scopes: .link(link))),
            .scoped(SemanticScopedRun(text: "R", traits: [.subscriptText],
                scopes: .language(language)))
        ]
    }

    static func style(
        _ level: SemanticHeadingLevel
    ) throws -> CanonicalBlockStyle
    {
        try #require(CanonicalBlockStyle(.heading(.section(
            SectionSemanticHeading(runs: [], level: level)
        ))))
    }

    static func expect(
        _ document: CanonicalDocument, level: SemanticHeadingLevel,
        runs: [SemanticRun]
    )
    {
        for identified in document.content.blocks
        {
            guard case let .heading(.section(section)) = identified.block
            else
            {
                Issue.record("Expected the exact section heading role")
                continue
            }
            #expect(section.level == level)
            #expect(section.runs == runs)
            for (actual, expected) in zip(section.runs, runs)
            {
                #expect(Array(actual.text.utf16) == Array(expected.text.utf16))
                #expect(actual.attributes == expected.attributes)
            }
        }
    }
}
