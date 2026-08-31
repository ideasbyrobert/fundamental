import Testing

@testable import FundamentalDocument

@Suite("A semantic table confidence target")
struct SemanticTableConfidenceTargetTests
{
    @Test("a table target has no position")
    func tableTargetHasNoPosition()
    {
        let target = SemanticTableConfidenceTarget.table

        guard case .table = target
        else
        {
            Issue.record("Expected a table confidence target")
            return
        }
    }

    @Test("a cell target preserves both indices")
    func cellTargetPreservesBothIndices() throws
    {
        let row = try #require(SemanticTableRowIndex(4))
        let cell = try #require(SemanticTableCellIndex(1))
        let target = SemanticTableConfidenceTarget.cell(
            row: row,
            cell: cell
        )

        guard case let .cell(admittedRow, admittedCell) = target
        else
        {
            Issue.record("Expected a cell confidence target")
            return
        }

        #expect(admittedRow == row)
        #expect(admittedCell == cell)
    }
}
