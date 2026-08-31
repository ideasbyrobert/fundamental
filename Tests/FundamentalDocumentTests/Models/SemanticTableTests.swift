import Testing

@testable import FundamentalDocument

@Suite("A semantic table")
struct SemanticTableTests
{
    @Test("minimal initialization uses the exact defaults")
    func minimalInitializationUsesDefaults()
    {
        let table = SemanticTable(rows: [])

        #expect(table.rows.isEmpty)
        #expect(table.headerRowCount == 0)
        #expect(table.columnAlignments.isEmpty)
        #expect(table.caption == nil)
        #expect(table.sourceLocation == nil)
        #expect(table.confidence == 1)
    }

    @Test("full initialization preserves supplied values and order")
    func fullInitializationPreservesValuesAndOrder()
    {
        let rows = [
            SemanticTableRow.header(
                HeaderSemanticTableRow(cells: [
                    SemanticTableCell.regular(
                        RegularSemanticTableCell(
                            runs: [SemanticRun(text: "First")]
                        )
                    )
                ])
            ),
            SemanticTableRow.body(
                BodySemanticTableRow(cells: [
                    SemanticTableCell.regular(
                        RegularSemanticTableCell(
                            runs: [SemanticRun(text: "Second")]
                        )
                    )
                ])
            )
        ]
        let alignments: [SemanticTableColumnAlignment] = [
            .leading,
            .trailing
        ]
        let caption = [
            SemanticRun(text: "Caption "),
            SemanticRun(text: "two", traits: [.emphasis])
        ]
        let table = SemanticTable(
            rows: rows,
            headerRowCount: 1,
            columnAlignments: alignments,
            caption: caption,
            sourceLocation: "table:2",
            confidence: 0.75
        )

        #expect(table.rows == rows)
        #expect(table.headerRowCount == 1)
        #expect(table.columnAlignments == alignments)
        #expect(table.caption == caption)
        #expect(table.sourceLocation == "table:2")
        #expect(table.confidence == 0.75)
    }
}
