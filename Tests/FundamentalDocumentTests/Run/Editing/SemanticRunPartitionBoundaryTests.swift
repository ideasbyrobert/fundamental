import Testing

@testable import FundamentalDocument

extension SemanticRunPartitionTests
{
    @Test("empty input refuses every nonzero bound")
    func emptyInputRefusesNonzeroBounds() throws
    {
        let zero = try Self.offset(0)
        let one = try Self.offset(1)

        #expect(SemanticRunPartition(
            runs: [],
            lowerBound: zero,
            upperBound: one
        ) == nil)
        #expect(SemanticRunPartition(
            runs: [],
            lowerBound: one,
            upperBound: one
        ) == nil)
    }

    @Test("reversed and out-of-bounds intervals are refused")
    func invalidIntervalsAreRefused() throws
    {
        let runs = [Self.direct("abc")]
        let pairs = [(2, 1), (0, 4), (4, 4)]

        for pair in pairs
        {
            #expect(SemanticRunPartition(
                runs: runs,
                lowerBound: try Self.offset(pair.0),
                upperBound: try Self.offset(pair.1)
            ) == nil)
        }
    }

    @Test("surrogate interiors are refused atomically")
    func surrogateInteriorsAreRefused() throws
    {
        let runs = [Self.direct("😀")]
        let cases = [(0, 1), (1, 2), (1, 1)]

        for item in cases
        {
            #expect(SemanticRunPartition(
                runs: runs,
                lowerBound: try Self.offset(item.0),
                upperBound: try Self.offset(item.1)
            ) == nil)
        }
    }

    @Test("a decomposed grapheme may partition at a scalar boundary")
    func decomposedGraphemeAdmitsScalarBoundary() throws
    {
        let partition = try Self.partition([Self.direct("e\u{301}")], 1, 2)

        #expect(partition.prefix == [Self.direct("e")])
        #expect(partition.selected == [Self.direct("\u{301}")])
        #expect(partition.suffix.isEmpty)
    }
}
