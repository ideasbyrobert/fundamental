import Testing

@testable import FundamentalWrapping

@Suite("Visual source coverage refusals")
struct WrappingPlanCoverageTests
{
    @Test("incomplete, overlapping, empty and out of bounds partitions fail",
          arguments: [
              [], [1 ..< 6], [0 ..< 2, 3 ..< 6], [0 ..< 3, 2 ..< 6],
              [2 ..< 4, 0 ..< 6], [0 ..< 5], [0 ..< 6, 6 ..< 6],
              [0 ..< 0, 0 ..< 6], [0 ..< 2, 2 ..< 2, 2 ..< 6],
              [0 ..< 7], [Int.min ..< 0], [0 ..< Int.max],
              [Int.max - 1 ..< Int.max]
          ] as [[Range<Int>]])
    func coverage(_ ranges: [Range<Int>])
    {
        let lines = ranges.enumerated().map
        {
            WrappingPlanFixture.line(
                $0.element, $0.offset == ranges.count - 1 ? .end : .soft
            )
        }
        #expect(WrappingPlan(
            source: WrappingSource("abcdef"), width: 100, lines: lines
        ) == nil)
    }

    @Test("soft and emergency breaks refuse grapheme interiors",
          arguments: [1, 3, 4, 5, 6, 7, 8],
          [WrappingLineBreak.soft, .emergency])
    func graphemeInterior(_ offset: Int, kind: WrappingLineBreak)
    {
        let lines = [
            WrappingPlanFixture.line(0 ..< offset, kind),
            WrappingPlanFixture.line(offset ..< 10)
        ]
        #expect(WrappingPlan(
            source: WrappingSource("e\u{301}👩🏽‍💻Z"), width: 100, lines: lines
        ) == nil)
    }

    @Test("the final content fragment must declare end of source",
          arguments: [WrappingLineBreak.soft, .emergency, .hard(.lineFeed)])
    func missingEnd(_ kind: WrappingLineBreak)
    {
        #expect(WrappingPlan(
            source: WrappingSource("abc"), width: 100,
            lines: [WrappingPlanFixture.line(0 ..< 3, kind)]
        ) == nil)
    }
}
