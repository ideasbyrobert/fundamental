import Testing

@testable import FundamentalDocument

extension EditableSemanticBlockTests
{
    @Test("a sourced regular table is refused")
    func sourcedRegularTableIsRefused() throws
    {
        let sourced = try SemanticTableAdmissionTests.sourced(
            SemanticTableAdmissionTests.table()
        )

        guard case .regular = sourced.table
        else
        {
            Issue.record("Expected a sourced regular table")
            return
        }

        let block = SemanticBlock.table(.sourced(sourced))
        #expect(EditableSemanticBlock(block) == nil)
    }
}
