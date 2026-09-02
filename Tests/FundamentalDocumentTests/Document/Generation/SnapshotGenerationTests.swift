import Testing

@testable import FundamentalDocument

@Suite("A snapshot generation")
struct SnapshotGenerationTests
{
    @Test("explicit construction preserves the full unsigned domain")
    func explicitConstructionPreservesValues()
    {
        let interior = SnapshotGeneration(42)
        let terminal = SnapshotGeneration(UInt64.max)

        #expect(SnapshotGeneration.zero == SnapshotGeneration(0))
        #expect(interior.value == 42)
        #expect(terminal.value == UInt64.max)
    }

    @Test("ordering follows exact unsigned values")
    func orderingFollowsUnsignedValues()
    {
        let values = [
            SnapshotGeneration(UInt64.max),
            SnapshotGeneration(7),
            .zero
        ]

        #expect(values.sorted().map(\.value) == [0, 7, UInt64.max])
    }

    @Test("checked succession advances exactly once")
    func checkedSuccessionAdvancesExactlyOnce() throws
    {
        let predecessor = SnapshotGeneration(8)
        let successor = try #require(
            SnapshotGeneration(after: predecessor)
        )

        #expect(predecessor.value == 8)
        #expect(successor.value == 9)
    }

    @Test("the maximum generation is terminal")
    func maximumGenerationIsTerminal()
    {
        let terminal = SnapshotGeneration(UInt64.max)

        #expect(SnapshotGeneration(after: terminal) == nil)
        #expect(terminal.value == UInt64.max)
    }
}
