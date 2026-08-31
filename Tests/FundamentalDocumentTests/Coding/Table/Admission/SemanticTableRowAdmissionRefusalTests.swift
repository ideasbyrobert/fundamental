import Testing

@testable import FundamentalDocument

extension SemanticTableRowAdmissionTests
{
    @Test("one invalid nested cell refuses every partial result")
    func oneInvalidNestedCellRefusesEveryPartialResult() throws
    {
        let legacy = Self.row(cells: [
            Self.cell("Valid"),
            Self.cell("Invalid", confidence: 2)
        ])
        let row = try #require(SemanticTableRowIndex(2))

        #expect(SemanticTableRowAdmissionAdapter.admit(
            legacy,
            rowIndex: row,
            role: .body
        ) == nil)
    }
}
