import Testing

@testable import FundamentalDocument

enum LayoutEmptyFontFixture
{
    static func blocks(_ runs: [SemanticRun]) throws -> [SemanticBlock]
    {
        let language = try #require(SemanticCodeLanguageIdentifier("swift"))
        return [
            .paragraph(SemanticParagraph(runs: runs)),
            .heading(.title(TitleSemanticHeading(runs: runs)))
        ] + SemanticHeadingLevel.allCases.map
        {
            .heading(.section(SectionSemanticHeading(runs: runs, level: $0)))
        } + [
            .code(.plain(PlainSemanticCodeBlock(runs: runs))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs, language: language
            )))
        ]
    }

    static func emptyRuns() throws -> [[SemanticRun]]
    {
        let traits: [SemanticInlineTrait] = [
            .strong, .emphasis, .underline, .strikethrough,
            .inlineCode, .superscript, .subscriptText
        ]
        return [
            [], [LayoutFixture.direct("")],
            try traits.map { LayoutFixture.direct("", traits: [$0]) }
                + [LayoutFixture.scoped("")]
        ]
    }
}
