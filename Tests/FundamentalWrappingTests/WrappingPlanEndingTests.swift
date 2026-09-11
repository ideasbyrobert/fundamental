import Testing

@testable import FundamentalWrapping

@Suite("Visual hard ending ownership")
struct WrappingPlanEndingTests
{
    @Test("each hard ending is owned exactly and retains the terminal line",
          arguments: [
              ("\n", WrappingLineEnding.lineFeed),
              ("\r", .carriageReturn), ("\r\n", .carriageReturnLineFeed),
              ("\u{85}", .nextLine), ("\u{B}", .verticalTab),
              ("\u{C}", .formFeed), ("\u{2028}", .lineSeparator),
              ("\u{2029}", .paragraphSeparator)
          ])
    func ending(_ text: String, kind: WrappingLineEnding) throws
    {
        let source = WrappingSource("a" + text)
        let end = source.utf16.count
        let first = WrappingPlanFixture.line(0 ..< end, .hard(kind))
        let last = WrappingPlanFixture.line(end ..< end)
        let plan = try #require(WrappingPlan(
            source: source, width: 100, lines: [first, last]
        ))
        #expect(plan.line(startingAt: end) == last)
        #expect(plan.source.substring(in: first.range)?.utf16.elementsEqual(
            source.utf16
        ) == true)
        #expect(WrappingPlan(source: source, width: 100, lines: [first]) == nil)
    }

    @Test("empty and consecutive source lines remain distinct")
    func emptyLines() throws
    {
        let empty = WrappingPlanFixture.line(0 ..< 0)
        let emptyPlan = try #require(WrappingPlan(
            source: WrappingSource(""), width: 100, lines: [empty]
        ))
        #expect(emptyPlan.line(startingAt: 0) == empty)
        let lines = [
            WrappingPlanFixture.line(0 ..< 1, .hard(.lineFeed)),
            WrappingPlanFixture.line(1 ..< 3, .hard(.carriageReturnLineFeed)),
            WrappingPlanFixture.line(3 ..< 4, .hard(.carriageReturn)),
            WrappingPlanFixture.line(4 ..< 4)
        ]
        let plan = try #require(WrappingPlan(
            source: WrappingSource("\n\r\n\r"), width: 100, lines: lines
        ))
        #expect(plan.lines == lines)
        #expect(WrappingPlan(
            source: WrappingSource(""), width: 100, lines: [empty, empty]
        ) == nil)
    }

    @Test("split, mismatched, omitted and detached endings fail",
          arguments: [
              [(0 ..< 4, WrappingLineBreak.end)],
              [(0 ..< 2, .hard(.carriageReturnLineFeed)), (2 ..< 4, .end)],
              [(0 ..< 3, .hard(.lineFeed)), (3 ..< 4, .end)],
              [(0 ..< 3, .soft), (3 ..< 4, .end)],
              [(0 ..< 3, .end), (3 ..< 4, .end)],
              [(0 ..< 1, .soft),
               (1 ..< 3, .hard(.carriageReturnLineFeed)), (3 ..< 4, .end)],
              [(0 ..< 1, .emergency),
               (1 ..< 3, .hard(.carriageReturnLineFeed)), (3 ..< 4, .end)],
              [(0 ..< 1, .hard(.carriageReturnLineFeed)), (1 ..< 4, .end)]
          ])
    func refusedEndings(_ choices: [(Range<Int>, WrappingLineBreak)])
    {
        let lines = choices.map { WrappingPlanFixture.line($0.0, $0.1) }
        #expect(WrappingPlan(
            source: WrappingSource("a\r\nb"), width: 100, lines: lines
        ) == nil)
    }
}
