import Testing

@testable import FundamentalDocument

@Suite("A semantic table cell index")
struct SemanticTableCellIndexTests
{
    @Test("nonnegative indices are admitted")
    func nonnegativeIndicesAreAdmitted() throws
    {
        for value in [0, 1, Int.max]
        {
            let index = try #require(SemanticTableCellIndex(value))

            #expect(index.value == value)
        }
    }

    @Test("negative indices are refused")
    func negativeIndicesAreRefused()
    {
        for value in [-1, Int.min]
        {
            #expect(SemanticTableCellIndex(value) == nil)
        }
    }
}
