import Testing

@testable import FundamentalDocument

@Suite("A semantic table row index")
struct SemanticTableRowIndexTests
{
    @Test("nonnegative indices are admitted")
    func nonnegativeIndicesAreAdmitted() throws
    {
        for value in [0, 1, Int.max]
        {
            let index = try #require(SemanticTableRowIndex(value))

            #expect(index.value == value)
        }
    }

    @Test("negative indices are refused")
    func negativeIndicesAreRefused()
    {
        for value in [-1, Int.min]
        {
            #expect(SemanticTableRowIndex(value) == nil)
        }
    }
}
