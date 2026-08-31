import Testing

@testable import FundamentalDocument

@Suite("A semantic table row")
struct SemanticTableRowTests
{
    @Test("the header form exposes exact cells")
    func headerFormExposesExactCells()
    {
        let cells: [SemanticTableCell] = [
            .regular(RegularSemanticTableCell(
                runs: [SemanticRun(text: "Header")]
            ))
        ]
        let row = SemanticTableRow.header(
            HeaderSemanticTableRow(cells: cells)
        )

        #expect(row.cells == cells)
        guard case .header = row
        else
        {
            Issue.record("Expected the header form")
            return
        }
    }

    @Test("the body form exposes exact cells")
    func bodyFormExposesExactCells()
    {
        let cells: [SemanticTableCell] = [
            .regular(RegularSemanticTableCell(
                runs: [SemanticRun(text: "Body")]
            ))
        ]
        let row = SemanticTableRow.body(
            BodySemanticTableRow(cells: cells)
        )

        #expect(row.cells == cells)
        guard case .body = row
        else
        {
            Issue.record("Expected the body form")
            return
        }
    }

    @Test("both forms admit empty rows and remain distinct")
    func bothFormsAdmitEmptyRowsAndRemainDistinct()
    {
        let header = SemanticTableRow.header(
            HeaderSemanticTableRow(cells: [])
        )
        let body = SemanticTableRow.body(
            BodySemanticTableRow(cells: [])
        )

        #expect(header.cells.isEmpty)
        #expect(body.cells.isEmpty)
        #expect(header != body)
    }
}
