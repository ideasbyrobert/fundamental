import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    func capacity(
        blocks: Int = 10_000,
        extents: Int = 100_000,
        fonts: Int = 1_000,
        rows: Int = 100_000,
        cells: Int = 100_000
    ) throws -> LayoutExtentIndexCapacity
    {
        try #require(LayoutExtentIndexCapacity(
            maximumBlockCount: blocks,
            maximumExtentCount: extents,
            maximumResolvedFontCount: fonts,
            maximumTableRowCount: rows,
            maximumTableCellCount: cells
        ))
    }

    func mixedBlocks() throws -> [SemanticBlock]
    {
        let language = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        return [
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("cafe\u{301} कि 👩🏽‍💻"),
                LayoutFixture.direct(" strong", traits: [.strong])
            ])),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: [LayoutFixture.direct("let value = 1")],
                language: language
            ))),
            .table(try LayoutFixture.table(captioned: false)),
            .table(try LayoutFixture.table(captioned: true))
        ]
    }

    func emptyTable() throws -> SemanticBlock
    {
        let content = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: []
        ))
        return .table(.semantic(.regular(
            RegularSemanticTable(content: content)
        )))
    }
}
