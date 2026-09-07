import Testing

@testable import FundamentalDocument

struct BlockRecordTestValue
{
    static func runs() throws -> [SemanticRun]
    {
        let link = try #require(SemanticLinkDestination(
            "https://example.test/"
        ))
        let language = try #require(SemanticLanguageIdentifier("hy"))
        return [
            SemanticRun(text: ""),
            SemanticRun(text: "é e\u{301} Հայերեն 👩‍💻"),
            SemanticRun(text: "\u{0000}\n\r\t", traits: [.strong, .emphasis]),
            .scoped(SemanticScopedRun(text: "link", scopes: .link(link))),
            .scoped(SemanticScopedRun(
                text: "language",
                scopes: .language(language)
            )),
            .scoped(SemanticScopedRun(
                text: "both",
                traits: [.underline, .inlineCode],
                scopes: .linkAndLanguage(link: link, language: language)
            ))
        ]
    }

    static func blocks() throws -> [SemanticBlock]
    {
        let runs = try runs()
        let language = try #require(SemanticCodeLanguageIdentifier(" Swift "))
        var blocks: [SemanticBlock] = [
            .paragraph(SemanticParagraph(runs: runs)),
            .paragraph(SemanticParagraph(runs: [])),
            .heading(.title(TitleSemanticHeading(runs: runs))),
            .code(.plain(PlainSemanticCodeBlock(runs: runs))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs,
                language: language
            )))
        ]
        blocks += SemanticHeadingLevel.allCases.map
        {
            .heading(.section(SectionSemanticHeading(runs: runs, level: $0)))
        }
        return blocks + (try tables()).map(SemanticBlock.table)
    }
}
