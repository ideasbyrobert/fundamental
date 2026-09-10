import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

enum WritingInlineFixture
{
    static let traits: [SemanticInlineTrait] = [
        .strong, .emphasis, .underline, .strikethrough, .inlineCode,
        .superscript, .subscriptText
    ]

    static func roles(_ runs: [SemanticRun]) throws -> [SemanticBlock]
    {
        let tag = try #require(SemanticCodeLanguageIdentifier(" SwIfT "))
        return [
            .paragraph(SemanticParagraph(runs: runs)),
            .heading(.title(TitleSemanticHeading(runs: runs)))
        ] + SemanticHeadingLevel.allCases.map
        {
            .heading(.section(SectionSemanticHeading(runs: runs, level: $0)))
        } + [
            .listItem(SemanticListItem(kind: .bulleted, runs: runs)),
            .listItem(SemanticListItem(kind: .numbered, runs: runs)),
            .code(.plain(PlainSemanticCodeBlock(runs: runs))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs, language: tag
            )))
        ]
    }

    @MainActor
    static func choose(
        _ trait: SemanticInlineTrait, enabled: Bool = true,
        in window: WritingTestWindow
    ) throws
    {
        let command = DocumentSessionCommand.typing(window.session.observation,
            SemanticInlineTraitAssignment(trait: trait, enabled: enabled))
        let result = window.session.submit(command)
        switch result
        {
        case .applied, .unchanged:
            break
        case .refused:
            Issue.record("Expected a canonical typing choice")
            return
        }
        try #require(window.controller.bridge.project(in: window.view))
    }

    static func runs(_ document: CanonicalDocument) throws -> [SemanticRun]
    {
        try document.content.blocks.flatMap
        {
            try #require(EditableSemanticBlock($0.block)).runs
        }
    }
}
