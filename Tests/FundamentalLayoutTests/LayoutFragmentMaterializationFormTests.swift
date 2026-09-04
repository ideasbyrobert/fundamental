import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    @Test("body title and six sections equal eager layout at both widths")
    func proseForms() throws
    {
        let body = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct("Body words cross a finite line boundary")
        ]))
        let title = SemanticBlock.heading(.title(
            TitleSemanticHeading(runs: [
                LayoutFixture.direct("Title words")
            ])
        ))
        let sections = SemanticHeadingLevel.allCases.map
        {
            SemanticBlock.heading(.section(SectionSemanticHeading(
                runs: [LayoutFixture.direct("Section words")],
                level: $0
            )))
        }
        for block in [body, title] + sections
        {
            for width in [120.0, 720]
            {
                let value = try product([block], width: width)
                let result = try diagnostics(
                    value,
                    extents: Array(value.index.extents.reversed())
                )
                try expectExact(
                    result,
                    product: value,
                    extents: value.index.extents
                )
            }
        }
    }

    @MainActor
    @Test("plain and language code equal eager layout at both widths")
    func codeForms() throws
    {
        let language = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        let runs = [LayoutFixture.direct(
            "let result = cafe\u{301} + कि + 👩🏽‍💻"
        )]
        let blocks: [SemanticBlock] = [
            .code(.plain(PlainSemanticCodeBlock(runs: runs))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs,
                language: language
            )))
        ]
        for block in blocks
        {
            for width in [120.0, 720]
            {
                let value = try product([block], width: width)
                let result = try diagnostics(
                    value,
                    extents: value.index.extents
                )
                try expectExact(
                    result,
                    product: value,
                    extents: value.index.extents
                )
            }
        }
    }

}
