import Testing

@testable import FundamentalDocument

@Suite("A semantic table evidence target")
struct SemanticTableEvidenceTargetTests
{
    @Test("a table target has no position")
    func tableTargetHasNoPosition()
    {
        let target = SemanticTableEvidenceTarget.table

        guard case .table = target
        else
        {
            Issue.record("Expected a table target")
            return
        }
    }

    @Test("a row target preserves its index")
    func rowTargetPreservesItsIndex() throws
    {
        let row = try #require(SemanticTableRowIndex(2))
        let target = SemanticTableEvidenceTarget.row(row)

        guard case let .row(admittedRow) = target
        else
        {
            Issue.record("Expected a row target")
            return
        }

        #expect(admittedRow == row)
    }

    @Test("a cell target preserves both indices")
    func cellTargetPreservesBothIndices() throws
    {
        let row = try #require(SemanticTableRowIndex(2))
        let cell = try #require(SemanticTableCellIndex(3))
        let target = SemanticTableEvidenceTarget.cell(
            row: row,
            cell: cell
        )

        guard case let .cell(admittedRow, admittedCell) = target
        else
        {
            Issue.record("Expected a cell target")
            return
        }

        #expect(admittedRow == row)
        #expect(admittedCell == cell)
    }
}
