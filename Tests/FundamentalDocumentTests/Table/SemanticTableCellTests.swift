import Testing

@testable import FundamentalDocument

@Suite("A semantic table cell")
struct SemanticTableCellTests
{
    @Test("regular and spanning forms preserve their leaves")
    func regularAndSpanningFormsPreserveTheirLeaves() throws
    {
        let regular = RegularSemanticTableCell(
            runs: [SemanticRun(text: "Body")],
            alignment: .leading
        )
        let extent = try #require(
            SemanticTableCellExtent(
                rowCount: 2,
                columnCount: 3
            )
        )
        let spanning = SpanningSemanticTableCell(
            runs: [SemanticRun(text: "Wide")],
            alignment: .trailing,
            extent: extent
        )

        #expect(SemanticTableCell.regular(regular) == .regular(regular))
        #expect(SemanticTableCell.spanning(spanning) == .spanning(spanning))
    }

    @Test("projections expose only occupied canonical facts")
    func projectionsExposeOnlyOccupiedCanonicalFacts() throws
    {
        let regular = SemanticTableCell.regular(
            RegularSemanticTableCell(
                runs: [SemanticRun(text: "Body")]
            )
        )
        let extent = try #require(
            SemanticTableCellExtent(
                rowCount: 4,
                columnCount: 2
            )
        )
        let spanning = SemanticTableCell.spanning(
            SpanningSemanticTableCell(
                runs: [SemanticRun(text: "Wide")],
                alignment: .center,
                extent: extent
            )
        )

        #expect(regular.runs == [SemanticRun(text: "Body")])
        #expect(regular.alignment == .unspecified)
        #expect(regular.rowCount == 1)
        #expect(regular.columnCount == 1)
        #expect(spanning.runs == [SemanticRun(text: "Wide")])
        #expect(spanning.alignment == .center)
        #expect(spanning.rowCount == 4)
        #expect(spanning.columnCount == 2)
    }
}
