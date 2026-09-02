import Testing

@testable import FundamentalDocument

@Suite("A semantic run partition")
struct SemanticRunPartitionTests
{
    @Test("empty input admits the zero interval")
    func emptyInputAdmitsZeroInterval() throws
    {
        let partition = try Self.partition([], 0, 0)

        #expect(partition.prefix.isEmpty)
        #expect(partition.selected.isEmpty)
        #expect(partition.suffix.isEmpty)
    }

    @Test("a whole interval preserves every run")
    func wholeIntervalPreservesEveryRun() throws
    {
        let runs = [Self.direct("ab"), Self.direct("cd", traits: [.strong])]
        let partition = try Self.partition(runs, 0, 4)

        #expect(partition.prefix.isEmpty)
        #expect(partition.selected == runs)
        #expect(partition.suffix.isEmpty)
    }

    @Test("a collapsed start leaves every run in suffix")
    func collapsedStartLeavesEveryRunInSuffix() throws
    {
        let runs = [Self.direct("ab"), Self.direct("cd")]
        let partition = try Self.partition(runs, 0, 0)

        #expect(partition.prefix.isEmpty)
        #expect(partition.selected.isEmpty)
        #expect(partition.suffix == runs)
    }

    @Test("a collapsed interior creates only occupied sides")
    func collapsedInteriorCreatesOnlyOccupiedSides() throws
    {
        let partition = try Self.partition([Self.direct("abcd")], 2, 2)

        #expect(partition.prefix == [Self.direct("ab")])
        #expect(partition.selected.isEmpty)
        #expect(partition.suffix == [Self.direct("cd")])
        #expect((partition.prefix + partition.suffix).allSatisfy
        {
            !$0.text.isEmpty
        })
    }

    @Test("a collapsed end leaves every run in prefix")
    func collapsedEndLeavesEveryRunInPrefix() throws
    {
        let runs = [Self.direct("ab"), Self.direct("cd")]
        let partition = try Self.partition(runs, 4, 4)

        #expect(partition.prefix == runs)
        #expect(partition.selected.isEmpty)
        #expect(partition.suffix.isEmpty)
    }
}
