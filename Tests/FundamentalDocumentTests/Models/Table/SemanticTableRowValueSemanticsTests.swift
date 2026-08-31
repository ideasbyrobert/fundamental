import Testing

@testable import FundamentalDocument

extension SemanticTableRowTests
{
    @Test("reconstruction leaves the principal row unchanged")
    func reconstructionLeavesPrincipalRowUnchanged()
    {
        let original = SemanticTableRow.body(
            BodySemanticTableRow(cells: [])
        )
        let changed = SemanticTableRow.header(
            HeaderSemanticTableRow(cells: [
                .regular(RegularSemanticTableCell(
                    runs: [SemanticRun(text: "Changed")]
                ))
            ])
        )

        #expect(original != changed)
        #expect(original.cells.isEmpty)
    }
}
