import Testing

@testable import FundamentalDocument

@Suite("A document revision")
struct DocumentRevisionTests
{
    @Test("explicit construction preserves the full unsigned domain")
    func explicitConstructionPreservesValues()
    {
        let interior = DocumentRevision(42)
        let terminal = DocumentRevision(UInt64.max)

        #expect(DocumentRevision.zero == DocumentRevision(0))
        #expect(interior.value == 42)
        #expect(terminal.value == UInt64.max)
    }

    @Test("ordering follows exact unsigned values")
    func orderingFollowsUnsignedValues()
    {
        let values = [
            DocumentRevision(UInt64.max),
            DocumentRevision(7),
            .zero
        ]

        #expect(values.sorted().map(\.value) == [0, 7, UInt64.max])
    }

    @Test("checked succession advances exactly once")
    func checkedSuccessionAdvancesExactlyOnce() throws
    {
        let predecessor = DocumentRevision(8)
        let successor = try #require(DocumentRevision(after: predecessor))

        #expect(predecessor.value == 8)
        #expect(successor.value == 9)
    }

    @Test("the maximum revision is terminal")
    func maximumRevisionIsTerminal()
    {
        let terminal = DocumentRevision(UInt64.max)

        #expect(DocumentRevision(after: terminal) == nil)
        #expect(terminal.value == UInt64.max)
    }
}
