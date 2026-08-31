import Testing

@testable import FundamentalDocument

@Suite("A semantic table content")
struct SemanticTableContentTests
{
    @Test("initialization preserves immutable ordered facts")
    func initializationPreservesImmutableOrderedFacts()
    {
        let headerRows = [
            HeaderSemanticTableRow(cells: [])
        ]
        let bodyRows = [
            BodySemanticTableRow(cells: []),
            BodySemanticTableRow(cells: [
                .regular(RegularSemanticTableCell(runs: []))
            ])
        ]
        let alignments: [SemanticTableColumnAlignment] = [
            .leading,
            .unspecified,
            .leading
        ]
        let content = SemanticTableContent(
            headerRows: headerRows,
            bodyRows: bodyRows,
            columnAlignments: alignments
        )

        #expect(content.headerRows == headerRows)
        #expect(content.bodyRows == bodyRows)
        #expect(content.columnAlignments == alignments)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let original = SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: []
        )
        let changed = SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [])],
            bodyRows: [BodySemanticTableRow(cells: [])],
            columnAlignments: [.center]
        )

        #expect(original != changed)
        #expect(original.headerRows.isEmpty)
        #expect(original.bodyRows.isEmpty)
        #expect(original.columnAlignments.isEmpty)
    }
}
