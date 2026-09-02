import Testing

@testable import FundamentalDocument

extension SemanticRunPartitionTests
{
    @Test("existing empty runs follow half-open placement")
    func existingEmptyRunsFollowHalfOpenPlacement() throws
    {
        let before = Self.direct("", traits: [.strong])
        let atLower = Self.direct("", traits: [.emphasis])
        let atUpper = Self.direct("", traits: [.inlineCode])
        let after = Self.direct("", traits: [.underline])
        let runs = [
            before,
            Self.direct("a"),
            atLower,
            Self.direct("bc"),
            atUpper,
            Self.direct("d"),
            after
        ]
        let extended = try Self.partition(runs, 1, 3)
        let collapsed = try Self.partition(runs, 1, 1)

        #expect(extended.prefix == [before, Self.direct("a")])
        #expect(extended.selected == [atLower, Self.direct("bc")])
        #expect(extended.suffix == [atUpper, Self.direct("d"), after])
        #expect(collapsed.prefix == [before, Self.direct("a")])
        #expect(collapsed.selected.isEmpty)
        #expect(collapsed.suffix == Array(runs.dropFirst(2)))
    }
}
