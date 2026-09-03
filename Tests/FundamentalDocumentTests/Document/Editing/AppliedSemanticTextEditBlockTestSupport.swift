import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextEditTests
{
    static func paragraph(_ runs: [SemanticRun]) -> SemanticBlock
    {
        .paragraph(SemanticParagraph(runs: runs))
    }

    static func title(_ runs: [SemanticRun]) -> SemanticBlock
    {
        .heading(.title(TitleSemanticHeading(runs: runs)))
    }

    static func section(
        _ runs: [SemanticRun],
        level: SemanticHeadingLevel
    ) -> SemanticBlock
    {
        .heading(.section(SectionSemanticHeading(
            runs: runs,
            level: level
        )))
    }

    static func plainCode(_ runs: [SemanticRun]) -> SemanticBlock
    {
        .code(.plain(PlainSemanticCodeBlock(runs: runs)))
    }

    static func taggedCode(
        _ runs: [SemanticRun]
    ) throws -> SemanticBlock
    {
        let language = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        return .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
            runs: runs,
            language: language
        )))
    }

    static func blockForms(
        sourceRuns: [SemanticRun],
        expectedRuns: [SemanticRun]
    ) throws -> [(SemanticBlock, SemanticBlock)]
    {
        var forms = [
            (paragraph(sourceRuns), paragraph(expectedRuns)),
            (title(sourceRuns), title(expectedRuns)),
            (plainCode(sourceRuns), plainCode(expectedRuns)),
            (
                try taggedCode(sourceRuns),
                try taggedCode(expectedRuns)
            )
        ]
        forms += SemanticHeadingLevel.allCases.map
        {
            (
                section(sourceRuns, level: $0),
                section(expectedRuns, level: $0)
            )
        }
        return forms
    }

    static func runs(
        in result: AppliedSemanticTextEdit,
        at index: Int = 0
    ) throws -> [SemanticRun]
    {
        let block = result.document.content.blocks[index].block
        return try #require(EditableSemanticBlock(block)).runs
    }

    static func text(
        in result: AppliedSemanticTextEdit
    ) throws -> String
    {
        try runs(in: result).map(\.text).joined()
    }
}
