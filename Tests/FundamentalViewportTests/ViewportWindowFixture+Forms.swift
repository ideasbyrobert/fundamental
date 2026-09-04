import Testing

@testable import FundamentalDocument

extension ViewportWindowFixture
{
    static func textBlocks() throws -> [SemanticBlock]
    {
        let unicode = [
            "cafe\u{301}",
            "कि",
            "مرحبا",
            "שלום",
            "✈️",
            "👩🏽‍💻",
            "🇦🇲"
        ].joined(separator: " ")
        let body = SemanticBlock.paragraph(SemanticParagraph(runs: [
            run(unicode),
            run(" strong", traits: [.strong]),
            run(" emphasis", traits: [.emphasis])
        ]))
        let title = SemanticBlock.heading(.title(
            TitleSemanticHeading(runs: [run("Title")])
        ))
        let sections = SemanticHeadingLevel.allCases.map
        {
            SemanticBlock.heading(.section(SectionSemanticHeading(
                runs: [run("Section \($0.rawValue) \(unicode)")],
                level: $0
            )))
        }
        let codeRuns = [run("let value = \"\(unicode)\"\nprint(value)")]
        let language = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        let code: [SemanticBlock] = [
            .code(.plain(PlainSemanticCodeBlock(runs: codeRuns))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: codeRuns,
                language: language
            )))
        ]
        return [body, title] + sections + code
    }
}
