import Testing

@testable import FundamentalDocument

extension SemanticRunPartitionTests
{
    @Test("cross-run cuts preserve exact attributes")
    func crossRunCutsPreserveExactAttributes() throws
    {
        let scope = try #require(SemanticRunAttributesTests.scopes().first)
        let runs = [
            Self.direct("ab", traits: [.strong]),
            Self.scoped("c😀d", scope, traits: [.emphasis]),
            Self.direct("ef", traits: [.inlineCode])
        ]
        let partition = try Self.partition(runs, 1, 7)

        #expect(partition.prefix == [Self.direct("a", traits: [.strong])])
        #expect(partition.selected == [
            Self.direct("b", traits: [.strong]),
            runs[1],
            Self.direct("e", traits: [.inlineCode])
        ])
        #expect(partition.suffix == [
            Self.direct("f", traits: [.inlineCode])
        ])
    }

    @Test("equal adjacent attributes remain separate runs")
    func equalAdjacentAttributesRemainSeparate() throws
    {
        let runs = ["a", "b", "c"].map
        {
            Self.direct($0, traits: [.strong])
        }
        let partition = try Self.partition(runs, 0, 3)

        #expect(partition.selected == runs)
        #expect(partition.selected.count == 3)
    }

    @Test("cuts preserve every scope form")
    func cutsPreserveEveryScopeForm() throws
    {
        let runs = try SemanticRunAttributesTests.scopes().map
        {
            Self.scoped("xy", $0, traits: [.emphasis])
        }
        let partition = try Self.partition(runs, 1, 5)

        #expect(partition.prefix[0].attributes == runs[0].attributes)
        #expect(partition.selected.map(\.attributes) == [
            runs[0].attributes,
            runs[1].attributes,
            runs[2].attributes
        ])
        #expect(partition.suffix[0].attributes == runs[2].attributes)
    }

    @Test("recombination preserves a grapheme spanning runs")
    func recombinationPreservesGraphemeSpanningRuns() throws
    {
        let runs = [
            Self.direct("e"),
            Self.direct("\u{301}"),
            Self.direct("😀z")
        ]
        let partition = try Self.partition(runs, 1, 4)
        let recombined = partition.prefix +
            partition.selected + partition.suffix

        #expect(Self.scalarValues(recombined) == Self.scalarValues(runs))
        #expect(Self.scalarValues(partition.prefix) == [0x65])
        #expect(Self.scalarValues(partition.selected) == [
            0x301,
            0x1F600
        ])
        #expect(Self.scalarValues(partition.suffix) == [0x7A])
        #expect(partition.selected == [runs[1], Self.direct("😀")])
    }

    @Test("partitioning leaves every original value unchanged")
    func partitioningLeavesOriginalValuesUnchanged() throws
    {
        let original = [
            Self.direct("before", traits: [.underline]),
            Self.direct("after", traits: [.strong])
        ]
        _ = try Self.partition(original, 2, 9)

        #expect(original == [
            Self.direct("before", traits: [.underline]),
            Self.direct("after", traits: [.strong])
        ])
    }
}
