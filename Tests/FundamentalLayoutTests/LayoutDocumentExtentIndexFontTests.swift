import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    @Test("all content fonts precede remaining structural fonts")
    func fontOrder() throws
    {
        let retainedBlocks: [SemanticBlock] = [
            try emptyTable(),
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("Later prose", traits: [.emphasis])
            ]))
        ]
        let retained = try product(retainedBlocks, width: 360)
        let retainedValues = try measurements(
            retained.projection,
            request: retained.request
        )
        let retainedTable = try #require(tableFacts(retainedValues[0]))
        #expect(retainedValues[0].contentFonts.isEmpty)
        #expect(!retainedValues[1].contentFonts.contains(
            retainedTable.structuralFont
        ))
        let retainedFonts = resolvedFonts(retainedValues)
        #expect(retainedFonts.last == retainedTable.structuralFont)
        #expect(retained.index.lineage.specification.resolvedFonts
            == retainedFonts)
        #expect(retained.snapshot.lineage.specification.resolvedFonts
            == retainedFonts)

        let repeatedBlocks: [SemanticBlock] = [
            try emptyTable(),
            .table(try LayoutFixture.table(captioned: false))
        ]
        let repeated = try product(repeatedBlocks, width: 360)
        let repeatedValues = try measurements(
            repeated.projection,
            request: repeated.request
        )
        let repeatedTable = try #require(tableFacts(repeatedValues[0]))
        #expect(repeatedValues[1].contentFonts.contains(
            repeatedTable.structuralFont
        ))
        #expect(repeated.index.lineage.specification.resolvedFonts
            == resolvedFonts(repeatedValues))
    }
}
