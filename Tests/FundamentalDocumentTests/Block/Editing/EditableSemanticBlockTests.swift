import Testing

@testable import FundamentalDocument

@Suite("Editable semantic block admission")
struct EditableSemanticBlockTests
{
    @Test("paragraphs preserve exact runs and re-embedding")
    func paragraphsPreserveExactValues() throws
    {
        let runs = try Self.runs()
        let block = SemanticBlock.paragraph(
            SemanticParagraph(runs: runs)
        )
        let editable = try #require(EditableSemanticBlock(block))
        #expect(editable.runs == runs)
        #expect(editable.semanticBlock == block)
    }

    @Test("title and every section level remain admitted")
    func headingsRemainAdmitted() throws
    {
        let runs = try Self.runs()
        let headings: [SemanticHeading] = [
            .title(TitleSemanticHeading(runs: runs))
        ] + SemanticHeadingLevel.allCases.map {
            .section(SectionSemanticHeading(
                runs: runs,
                level: $0
            ))
        }

        for heading in headings
        {
            let block = SemanticBlock.heading(heading)
            let editable = try #require(EditableSemanticBlock(block))
            #expect(editable.runs == runs)
            #expect(editable.semanticBlock == block)
        }
    }

    @Test("plain and language-tagged code remain admitted")
    func codeFormsRemainAdmitted() throws
    {
        let runs = try Self.runs()
        let language = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        let forms: [SemanticCodeBlock] = [
            .plain(PlainSemanticCodeBlock(runs: runs)),
            .languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs,
                language: language
            ))
        ]

        for code in forms
        {
            let block = SemanticBlock.code(code)
            let editable = try #require(EditableSemanticBlock(block))
            #expect(editable.runs == runs)
            #expect(editable.semanticBlock == block)
        }
    }

    @Test("tables are refused without an admitted value")
    func tablesAreRefused() throws
    {
        let sourced = try SemanticTableAdmissionTests.sourced(
            SemanticTableAdmissionTests.table(
                caption: [SemanticRun(text: "Caption")]
            )
        )
        let records: [SemanticTableRecord] = [
            SemanticBlockTests.emptyTableRecord(),
            .semantic(sourced.table),
            .sourced(sourced)
        ]
        for record in records
        {
            #expect(EditableSemanticBlock(.table(record)) == nil)
        }
    }

    private static func runs() throws -> [SemanticRun]
    {
        let link = try #require(
            SemanticLinkDestination("chapter-one")
        )
        return [
            SemanticRun(text: "First"),
            .scoped(SemanticScopedRun(
                text: "Second",
                traits: [.emphasis],
                scopes: .link(link)
            ))
        ]
    }
}
