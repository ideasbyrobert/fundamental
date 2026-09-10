import Testing

@testable import FundamentalDocument

extension MacReaderDocumentFixture
{
    static func admittedBlocks() throws -> [SemanticBlock]
    {
        let language = try #require(SemanticCodeLanguageIdentifier("swift"))
        let headings = SemanticHeadingLevel.allCases.map
        {
            SemanticBlock.heading(.section(SectionSemanticHeading(
                runs: [SemanticRun(text: "Heading \($0.rawValue) Раздел")],
                level: $0
            )))
        }
        return [
            paragraph("Body e\u{301} 😀"),
            .heading(.title(TitleSemanticHeading(
                runs: [SemanticRun(text: "A supplied document ✈️")]
            )))
        ] + headings + [
            .code(.plain(PlainSemanticCodeBlock(
                runs: [SemanticRun(text: "let π = 3.14")]
            ))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: [SemanticRun(text: "let value = \"Swift\"")],
                language: language
            )))
        ]
    }

    static func runs(_ block: SemanticBlock) throws -> [SemanticRun]
    {
        switch block
        {
        case let .paragraph(value):
            value.runs
        case let .heading(value):
            value.runs
        case let .listItem(value):
            value.runs
        case let .code(value):
            value.runs
        case .table:
            throw MacOracleTestFailure.admission
        }
    }
}
