import Testing

@testable import FundamentalWrapping

@Suite("Complete visual source plans")
struct WrappingPlanTests
{
    @Test("soft and hard choices reconstruct exact source")
    func mixedPlan() throws
    {
        let source = WrappingSource("alpha beta\r\nγδ")
        let lines = [
            WrappingPlanFixture.line(0 ..< 6, .soft, advance: 54),
            WrappingPlanFixture.line(
                6 ..< 12, .hard(.carriageReturnLineFeed),
                indentation: 18, advance: 36
            ),
            WrappingPlanFixture.line(12 ..< 14, advance: 20)
        ]
        let plan = try #require(WrappingPlan(
            source: source, width: 90, lines: lines
        ))
        #expect(plan.source == source)
        #expect(plan.width == 90)
        #expect(plan.lines == lines)
        let pieces = try plan.lines.map
        {
            try #require(plan.source.substring(in: $0.range))
        }
        #expect(pieces == ["alpha ", "beta\r\n", "γδ"])
        #expect(pieces.joined().utf16.elementsEqual(source.utf16))
    }

    @Test("emergency choices keep complete graphemes")
    func emergencyPlan() throws
    {
        let source = WrappingSource("e\u{301}👩🏽‍💻Z")
        let lines = [
            WrappingPlanFixture.line(0 ..< 2, .emergency, advance: 10),
            WrappingPlanFixture.line(2 ..< 9, .emergency, advance: 18),
            WrappingPlanFixture.line(9 ..< 10, advance: 10)
        ]
        let plan = try #require(WrappingPlan(
            source: source, width: 18, lines: lines
        ))
        let pieces = try plan.lines.map
        {
            try #require(plan.source.substring(in: $0.range))
        }
        #expect(pieces == ["e\u{301}", "👩🏽‍💻", "Z"])
        #expect(pieces.joined().utf16.elementsEqual(source.utf16))
    }

    @Test("plan identity retains exact canonically equivalent spelling")
    func exactSpelling() throws
    {
        let first = WrappingSource("\u{212B}")
        let second = WrappingSource("\u{C5}")
        #expect(first.text == second.text)
        let lines = [WrappingPlanFixture.line(0 ..< 1, advance: 10)]
        let firstPlan = try #require(WrappingPlan(
            source: first, width: 20, lines: lines
        ))
        let secondPlan = try #require(WrappingPlan(
            source: second, width: 20, lines: lines
        ))
        #expect(firstPlan != secondPlan)
        #expect(Set([firstPlan, secondPlan, firstPlan]).count == 2)
    }
}
