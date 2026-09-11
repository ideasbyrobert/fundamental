import Testing

@testable import FundamentalWrapping

@Suite("Exact visual line lookup")
struct WrappingPlanLookupTests
{
    @Test("only exact starts match, including the terminal empty line")
    func exactStarts() throws
    {
        let lines = [
            WrappingPlanFixture.line(0 ..< 2, .soft),
            WrappingPlanFixture.line(2 ..< 6, .hard(.lineFeed)),
            WrappingPlanFixture.line(6 ..< 6)
        ]
        let plan = try #require(WrappingPlan(
            source: WrappingSource("abcde\n"), width: 100, lines: lines
        ))
        for line in lines
        {
            #expect(plan.line(startingAt: line.range.lowerBound) == line)
        }
        for offset in [Int.min, -1, 1, 3, 4, 5, 7, Int.max]
        {
            #expect(plan.line(startingAt: offset) == nil)
        }
    }

    @Test("many source lines retain all starts without neighboring matches")
    func manyLines() throws
    {
        let count = 16_384
        let source = WrappingSource(String(repeating: "x\r\n", count: count))
        var lines = (0 ..< count).map
        {
            WrappingPlanFixture.line(
                $0 * 3 ..< ($0 + 1) * 3, .hard(.carriageReturnLineFeed)
            )
        }
        let end = count * 3
        lines.append(WrappingPlanFixture.line(end ..< end))
        let plan = try #require(WrappingPlan(
            source: source, width: 100, lines: lines
        ))
        for (index, line) in lines.enumerated()
        {
            #expect(plan.line(startingAt: index * 3) == line)
            #expect(plan.line(startingAt: index * 3 + 1) == nil)
            #expect(plan.line(startingAt: index * 3 + 2) == nil)
        }
        #expect(plan.lines.count == count + 1)
        #expect(plan.source.utf16.elementsEqual(source.text.utf16))
    }
}
